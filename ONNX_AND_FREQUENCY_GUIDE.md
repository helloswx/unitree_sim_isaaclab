# 📚 ONNX 模型与控制频率详解

## 第一部分：什么是 ONNX 模型？

### 🎯 通俗解释

**ONNX（Open Neural Network Exchange）** 就像是一个"通用翻译器"：

1. **训练阶段**：研究人员用 PyTorch/TensorFlow 训练神经网络（就像教机器人如何完成任务）
2. **导出阶段**：把训练好的模型转换成 ONNX 格式（就像把"中文说明书"翻译成"世界语"）
3. **推理阶段**：任何支持 ONNX 的程序都能运行这个模型（任何"说世界语"的人都能看懂说明书）

### 🔍 为什么用 ONNX？

- ✅ **跨平台**：可以在不同编程语言和框架中使用（Python、C++、JavaScript 等）
- ✅ **高效推理**：专门优化过的推理引擎，运行速度快
- ✅ **无需训练代码**：只需要模型文件，不需要原始的 PyTorch 训练代码
- ✅ **标准化**：业界标准格式，兼容性好

---

## 第二部分：代码中的 ONNX 模型使用

### 📖 代码解析

让我们看看 `action_provider/action_provider_wh_dds.py` 中如何使用 ONNX 模型：

```python
# 第 8 行：导入 ONNX 运行时库
import onnxruntime as ort

# 第 296-312 行：加载和使用 ONNX 模型
def load_policy(self, path):
    """根据文件扩展名选择加载方式"""
    ext = os.path.splitext(path)[1].lower()
    if ext == ".onnx":
        return self.load_onnx_policy(path)  # 如果是 .onnx 文件
    elif ext == ".pt":
        return self.load_jit_pt_policy(path)  # 如果是 PyTorch 文件

def load_onnx_policy(self, path):
    """加载 ONNX 模型"""
    # 1. 创建 ONNX 推理会话（就像打开一个"计算器"）
    model = ort.InferenceSession(path)
    
    # 2. 定义一个推理函数（就像定义如何使用这个"计算器"）
    def run_inference(input_tensor):
        # 2.1 准备输入数据：把 PyTorch 张量转为 NumPy 数组
        ort_inputs = {model.get_inputs()[0].name: input_tensor.cpu().numpy()}
        
        # 2.2 运行推理：输入观测数据，输出动作
        ort_outs = model.run(None, ort_inputs)
        
        # 2.3 转换回 PyTorch 张量
        return torch.tensor(ort_outs[0], device=self.env.device)
    
    # 3. 返回这个推理函数（以后可以直接调用）
    return run_inference
```

### 🔄 工作流程

```
机器人观测数据（关节角度、速度、相机图像等）
    ↓
转换为模型输入格式（NumPy 数组）
    ↓
ONNX 模型推理（神经网络计算）
    ↓
输出动作（关节目标位置/速度）
    ↓
转换为 PyTorch 张量
    ↓
发送给机器人执行
```

### 💡 实际例子

假设你有一个训练好的模型 `policy.onnx`，它学会了"抓取红色木块"：

```python
# 1. 加载模型（只需要运行一次）
policy = load_onnx_policy("assets/model/policy.onnx")

# 2. 每次控制循环中：
#    - 获取当前观测（机器人看到了什么）
observations = get_robot_observations()  # 例如：[关节角度, 相机图像, ...]

#    - 模型推理（模型"思考"应该做什么动作）
actions = policy(observations)  # 例如：[左臂角度, 右臂角度, 夹爪开合度, ...]

#    - 执行动作（机器人执行动作）
robot.execute(actions)
```

---

## 第三部分：控制频率详解

### 📊 各种控制方式的频率要求

| 控制方式 | 频率要求 | 代码位置 | 说明 |
|---------|---------|---------|------|
| **主控制循环** | **100 Hz** (默认) | `sim_main.py:49` | 整个仿真循环的频率 |
| **低层控制器** | **500 Hz** (默认) | `robot_control_system.py:17` | 机器人底层控制频率 |
| **键盘控制** | **50 Hz** | `send_commands_keyboard.py:210` | 键盘输入更新频率 |
| **DDS 发布** | **100 Hz** (默认) | `dds_master.py:40` | DDS 消息发布频率 |
| **ONNX 推理** | **跟随主循环** | `action_provider_wh_dds.py` | 每次控制循环调用一次 |
| **相机图像** | **30 Hz** | `episode_writer.py:14` | 图像采集频率 |
| **VLM 控制** | **10-20 Hz** (推荐) | `vlm_controller_example.py:305` | 视觉语言模型推理频率 |

---

### 🔍 详细频率说明

#### 1. 主控制循环：100 Hz（默认）

**位置**：`sim_main.py`

```python
# 第 49 行：定义默认频率
parser.add_argument("--step_hz", type=int, default=100, help="control frequency")

# 使用方式：
python sim_main.py --step_hz 100  # 100 Hz（每秒 100 次循环）
python sim_main.py --step_hz 50   # 50 Hz（每秒 50 次循环）
```

**含义**：
- 每秒执行 100 次控制循环
- 每次循环：获取观测 → 计算动作 → 执行动作 → 更新物理仿真
- **为什么是 100 Hz？** 平衡了实时性和计算负担

**实际效果**：
- 100 Hz = 每 10 毫秒执行一次
- 如果降低到 50 Hz，机器人反应会变慢，但计算负担更小

---

#### 2. 低层控制器：500 Hz（默认）

**位置**：`layeredcontrol/robot_control_system.py`

```python
# 第 17 行：定义低层控制频率
class ControlConfig:
    step_hz: int = 500  # 每秒 500 次

# 第 34 行：计算时间间隔
self._step_interval = 1.0 / config.step_hz  # 0.002 秒 = 2 毫秒
```

**含义**：
- 机器人底层控制器的执行频率
- 比主循环更高，确保控制精度
- **为什么是 500 Hz？** 机器人关节需要高频率控制才能保持稳定

**实际效果**：
- 500 Hz = 每 2 毫秒执行一次底层控制
- 这确保了机器人动作的平滑性和稳定性

---

#### 3. 键盘控制：50 Hz

**位置**：`send_commands_keyboard.py`

```python
# 第 210 行：键盘更新频率
time.sleep(0.02)  # 50Hz update frequency
# 0.02 秒 = 50 Hz
```

**含义**：
- 每秒检查 50 次键盘输入
- 更新移动命令（前进、后退、转向等）
- **为什么是 50 Hz？** 人类操作键盘的速度不需要太高频率

**实际效果**：
- 50 Hz = 每 20 毫秒检查一次键盘
- 对于人类操作来说已经足够流畅

---

#### 4. DDS 通信：100 Hz（默认）

**位置**：`dds/dds_master.py`

```python
# 第 40 行：默认发布频率
self._default_pub_interval: float = 0.01  # 100Hz default
# 0.01 秒 = 100 Hz

# 第 124-130 行：可以自定义频率
def set_publish_rate(self, name: str, hz: float) -> None:
    """设置特定对象的发布频率"""
    if name in self.objects and hz > 0:
        self._pub_interval[name] = 1.0 / hz
```

**含义**：
- DDS 消息的发布频率（机器人状态、命令等）
- 默认 100 Hz，可以针对不同消息类型调整
- **为什么是 100 Hz？** 与主控制循环同步，确保实时性

**实际效果**：
- 100 Hz = 每 10 毫秒发布一次消息
- 外部程序可以实时获取机器人状态

---

#### 5. ONNX 模型推理：跟随主循环

**位置**：`action_provider/action_provider_wh_dds.py`

```python
# ONNX 推理在主控制循环中被调用
# 频率 = 主控制循环频率 = 100 Hz（默认）

def get_action(self, env):
    # 每次主循环调用一次
    observations = self.compute_current_observations()
    actions = self.policy(observations)  # ONNX 推理
    return actions
```

**含义**：
- ONNX 模型推理频率 = 主控制循环频率
- 默认 100 Hz，即每秒推理 100 次
- **为什么跟随主循环？** 每次控制循环都需要新的动作

**实际效果**：
- 100 Hz = 每秒推理 100 次
- 如果模型推理太慢（> 10 毫秒），会影响整体性能

---

#### 6. VLM 控制：10-20 Hz（推荐）

**位置**：`vlm_controller_example.py`

```python
# 第 305 行：VLM 控制频率
def run(self, task_description: str = "抓取红色木块", frequency: float = 10.0):
    """
    frequency: 控制频率（Hz）
    推荐 10-20 Hz，不要太高
    """
    dt = 1.0 / frequency  # 例如：10 Hz = 0.1 秒
```

**含义**：
- VLM（视觉语言模型）推理通常较慢
- 推荐 10-20 Hz，即每秒推理 10-20 次
- **为什么这么低？** VLM 推理需要处理图像和语言，计算量大

**实际效果**：
- 10 Hz = 每 100 毫秒推理一次
- 20 Hz = 每 50 毫秒推理一次
- 对于高层决策来说已经足够

---

### ⚙️ 如何调整频率？

#### 调整主控制循环频率

```bash
# 降低频率（更省资源，但反应变慢）
python sim_main.py --step_hz 50

# 提高频率（更快反应，但需要更多计算资源）
python sim_main.py --step_hz 200
```

#### 调整键盘控制频率

编辑 `send_commands_keyboard.py`：

```python
# 第 210 行：修改 sleep 时间
time.sleep(0.01)  # 100 Hz（更快）
time.sleep(0.05)  # 20 Hz（更慢）
```

#### 调整 DDS 发布频率

在代码中调用：

```python
from dds.dds_master import dds_manager

# 设置特定对象的发布频率
dds_manager.set_publish_rate("robot_state", 50)  # 50 Hz
dds_manager.set_publish_rate("gripper_state", 100)  # 100 Hz
```

---

### 📈 频率与性能的关系

| 频率 | 延迟 | CPU 使用 | 适用场景 |
|------|------|----------|---------|
| **10 Hz** | 100 ms | 低 | VLM 推理、高层决策 |
| **50 Hz** | 20 ms | 中 | 键盘控制、人类操作 |
| **100 Hz** | 10 ms | 中高 | 主控制循环、DDS 通信 |
| **500 Hz** | 2 ms | 高 | 底层控制、关节控制 |

**经验法则**：
- **实时控制**：≥ 100 Hz
- **人类操作**：50 Hz 足够
- **AI 推理**：10-20 Hz 足够
- **底层控制**：≥ 500 Hz

---

### 🎯 总结

1. **ONNX 模型**：
   - 是训练好的神经网络的"通用格式"
   - 不需要训练代码，只需要模型文件
   - 推理速度快，跨平台兼容

2. **控制频率**：
   - **主循环**：100 Hz（可调整）
   - **底层控制**：500 Hz（固定）
   - **键盘控制**：50 Hz
   - **DDS 通信**：100 Hz（可调整）
   - **VLM 推理**：10-20 Hz（推荐）

3. **性能优化**：
   - 如果性能不足，降低主循环频率（`--step_hz 50`）
   - 如果反应太慢，提高主循环频率（`--step_hz 200`）
   - VLM 等 AI 模型不需要太高频率（10-20 Hz 足够）

