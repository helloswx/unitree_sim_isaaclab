# 🤖 VLM 接入指南

## 📋 机器人控制方式总结

### 1. DDS 通信（最灵活，推荐用于 VLM）

**通道列表：**

| 通道名称 | 消息类型 | 控制内容 | 适用场景 |
|---------|---------|---------|---------|
| `rt/lowcmd` | `LowCmd_` | 29个关节位置/速度/力矩 | 精确控制所有关节 |
| `rt/run_command/cmd` | `String_` | 移动命令 `[x_vel, y_vel, yaw_vel, height]` | Wholebody 移动 |
| `rt/unitree_actuator/cmd` | `MotorCmds_` | 夹爪控制 | 二指夹爪 |
| `rt/dex3/cmd` | `MotorCmds_` | 三指灵巧手控制 | 三指手 |
| `rt/inspire/cmd` | `MotorCmds_` | Inspire 手控制 | Inspire 手 |

### 2. 共享内存（内部使用）

- `isaac_robot_state` - 读取机器人状态
- `dds_robot_cmd` - 写入机器人命令

### 3. 其他方式

- 键盘控制（`send_commands_keyboard.py`）
- 策略模型（ONNX）
- Replay 数据

---

## 🎯 VLM 接入方案

### 方案 A: 独立 VLM 控制程序（推荐）

**优点：**
- 解耦，不影响仿真代码
- 易于调试和修改
- 可以支持多种 VLM

**实现：** 使用 `vlm_controller_example.py` 作为模板

### 方案 B: 集成到 Action Provider

**优点：**
- 与仿真紧密集成
- 可以访问环境内部状态

**实现：** 创建 `action_provider/action_provider_vlm.py`

---

## 🔧 实现步骤

### 步骤 1: 准备 VLM API 服务

**选项 1: 使用 OpenAI GPT-4V**
```python
import openai

client = openai.OpenAI(api_key="your-api-key")

response = client.chat.completions.create(
    model="gpt-4-vision-preview",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "分析图像并生成机器人控制命令"},
                {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{image_base64}"}}
            ]
        }
    ]
)
```

**选项 2: 使用 Claude**
```python
import anthropic

client = anthropic.Anthropic(api_key="your-api-key")

message = client.messages.create(
    model="claude-3-opus-20240229",
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "image", "source": {"type": "base64", "media_type": "image/jpeg", "data": image_base64}},
                {"type": "text", "text": "生成机器人控制命令"}
            ]
        }
    ]
)
```

**选项 3: 本地 VLM（如 LLaVA）**
```python
# 使用 transformers 库
from transformers import LlavaProcessor, LlavaForConditionalGeneration

processor = LlavaProcessor.from_pretrained("llava-hf/llava-1.5-7b-hf")
model = LlavaForConditionalGeneration.from_pretrained("llava-hf/llava-1.5-7b-hf")
```

### 步骤 2: 获取相机图像

**方法 1: 从图像服务器（推荐）**

```python
import zmq
import numpy as np

context = zmq.Context()
socket = context.socket(zmq.SUB)
socket.connect("tcp://localhost:5555")
socket.setsockopt_string(zmq.SUBSCRIBE, "")

# 接收图像
image_data = socket.recv()
# 根据实际格式解析图像
```

**方法 2: 从共享内存**

```python
from image_server.shared_memory_utils import MultiImageReader

reader = MultiImageReader()
image_dict = reader.read()
front_camera = image_dict.get('front_camera')  # (480, 640, 3)
```

**方法 3: 从环境观测（如果集成到 Action Provider）**

```python
obs = env.get_obs()
camera_image = obs['camera_image']  # shape: (480, 640, 3)
```

### 步骤 3: 构建 VLM 提示词

```python
prompt = f"""
你是一个机器人控制专家。根据给定的图像，生成机器人控制命令。

任务: {task_description}

当前场景图像: [图像]

请分析图像并生成控制命令：
1. 左臂7个关节的目标角度（弧度）
2. 右臂7个关节的目标角度（弧度）
3. 夹爪开合度（0.0=完全张开, 1.0=完全闭合）

关节顺序（左臂）:
- left_shoulder_pitch_joint
- left_shoulder_roll_joint
- left_shoulder_yaw_joint
- left_elbow_joint
- left_wrist_roll_joint
- left_wrist_pitch_joint
- left_wrist_yaw_joint

关节顺序（右臂）:
- right_shoulder_pitch_joint
- right_shoulder_roll_joint
- right_shoulder_yaw_joint
- right_elbow_joint
- right_wrist_roll_joint
- right_wrist_pitch_joint
- right_wrist_yaw_joint

请返回 JSON 格式:
{{
    "left_arm": [角度1, 角度2, ..., 角度7],
    "right_arm": [角度1, 角度2, ..., 角度7],
    "gripper": 0.5,
    "explanation": "动作说明"
}}
"""
```

### 步骤 4: 发送 DDS 命令

```python
from unitree_sdk2py.core.channel import ChannelPublisher, ChannelFactoryInitialize
from unitree_sdk2py.idl.unitree_hg.msg.dds_ import LowCmd_
from unitree_sdk2py.idl.default import unitree_hg_msg_dds__LowCmd_
from unitree_sdk2py.utils.crc import CRC

# 初始化
ChannelFactoryInitialize(1)
publisher = ChannelPublisher("rt/lowcmd", LowCmd_)
publisher.Init()
crc = CRC()

# 创建命令
cmd = unitree_hg_msg_dds__LowCmd_()

# 设置左臂（关节 15-21）
for i, angle in enumerate(left_arm):
    cmd.motor_cmd[15 + i].q = angle
    cmd.motor_cmd[15 + i].kp = 100.0
    cmd.motor_cmd[15 + i].kd = 2.0

# 设置右臂（关节 22-28）
for i, angle in enumerate(right_arm):
    cmd.motor_cmd[22 + i].q = angle
    cmd.motor_cmd[22 + i].kp = 100.0
    cmd.motor_cmd[22 + i].kd = 2.0

# 计算 CRC 并发布
cmd.crc = crc.Crc(cmd)
publisher.Write(cmd)
```

---

## 📝 完整示例

### 使用示例代码

```bash
# 1. 启动仿真
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-PickPlace-RedBlock-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --render_interval 10

# 2. 运行 VLM 控制器
python vlm_controller_example.py \
    --vlm_api_url http://localhost:8000/vlm/infer \
    --task "抓取红色木块" \
    --frequency 10.0
```

---

## 🔍 关键信息

### G1 机器人关节顺序

**总关节数：** 33 个

**关节索引：**
- 0-14: 腿部关节（15个）
- 15-21: 左臂关节（7个）
  - 15: left_shoulder_pitch_joint
  - 16: left_shoulder_roll_joint
  - 17: left_shoulder_yaw_joint
  - 18: left_elbow_joint
  - 19: left_wrist_roll_joint
  - 20: left_wrist_pitch_joint
  - 21: left_wrist_yaw_joint
- 22-28: 右臂关节（7个）
  - 22: right_shoulder_pitch_joint
  - 23: right_shoulder_roll_joint
  - 24: right_shoulder_yaw_joint
  - 25: right_elbow_joint
  - 26: right_wrist_roll_joint
  - 27: right_wrist_pitch_joint
  - 28: right_wrist_yaw_joint
- 29-32: 手部关节（4个）

### DDS 通道配置

**重要：** 所有 DDS 实例必须使用相同的通道号：

```python
ChannelFactoryInitialize(1)  # 通道 1
```

### 图像格式

- **分辨率：** 480x640
- **格式：** RGB (3通道)
- **数据类型：** uint8 (0-255)

---

## 🚀 快速开始

1. **使用提供的示例代码：**
   ```bash
   python vlm_controller_example.py --vlm_api_url YOUR_VLM_API
   ```

2. **修改 VLM API 地址：**
   - 编辑 `vlm_controller_example.py`
   - 修改 `vlm_api_url` 参数

3. **实现 VLM 查询函数：**
   - 根据你使用的 VLM（GPT-4V, Claude, LLaVA 等）
   - 实现 `query_vlm` 方法

4. **测试：**
   - 启动仿真
   - 运行 VLM 控制器
   - 观察机器人动作

---

## 📚 相关文件

- **`vlm_controller_example.py`** - VLM 控制器示例代码
- **`action_provider/action_provider_dds.py`** - DDS Action Provider 实现
- **`dds/g1_robot_dds.py`** - G1 机器人 DDS 通信
- **`image_server/image_server.py`** - 图像服务器

---

## ⚠️ 注意事项

1. **DDS 通道号必须一致：** 所有程序使用 `ChannelFactoryInitialize(1)`
2. **图像格式：** 确保图像格式正确（RGB, 480x640）
3. **控制频率：** 建议 10-20 Hz，不要太高
4. **关节限制：** 注意关节角度限制，避免超出范围
5. **错误处理：** 添加适当的错误处理和超时机制

---

## 🔗 扩展阅读

- Unitree SDK2 文档：了解 DDS 通信细节
- VLM API 文档：根据使用的 VLM 查看 API 文档
- Isaac Lab 文档：了解环境观测和动作格式

