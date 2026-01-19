# 🎮 PD 控制器详解与使用指南

## 第一部分：什么是 PD 控制器？

### 🎯 通俗解释

**PD 控制器**（Proportional-Derivative Controller）就像是一个"智能弹簧"：

想象你要控制一个门，让它停在某个位置：

1. **P（比例）控制**：门离目标位置越远，你推的力气越大
   - 就像弹簧：拉得越远，回弹力越大
   - **kp**（比例增益）：控制"弹簧的硬度"

2. **D（微分）控制**：门移动得越快，你越要"刹车"
   - 就像阻尼器：速度越快，阻力越大
   - **kd**（微分增益）：控制"阻尼的大小"

### 📐 数学公式

```
力矩 = kp × (目标位置 - 当前位置) + kd × (目标速度 - 当前速度)
```

**通俗理解**：
- **kp × 位置误差**：如果关节偏离目标，产生"拉回"的力
- **kd × 速度误差**：如果关节移动太快，产生"刹车"的力

---

## 第二部分：PD 控制器的工作原理

### 🔍 详细解释

#### 1. P（比例）控制 - 位置误差

**作用**：让关节"想要"到达目标位置

**例子**：
```
目标位置：0.5 弧度
当前位置：0.3 弧度
误差：0.2 弧度

如果 kp = 100：
力矩 = 100 × 0.2 = 20 N·m（产生 20 牛·米的力矩来"拉"关节）
```

**特点**：
- ✅ **kp 越大**：关节越"硬"，越不容易被推动
- ✅ **kp 太小**：关节太"软"，反应慢，可能到不了目标位置
- ⚠️ **kp 太大**：关节会"抖动"，不稳定

#### 2. D（微分）控制 - 速度误差

**作用**：防止关节"冲过头"，提供阻尼

**例子**：
```
目标速度：0 弧度/秒（静止）
当前速度：2.0 弧度/秒（快速移动）
速度误差：-2.0 弧度/秒

如果 kd = 2：
阻尼力矩 = 2 × (-2.0) = -4 N·m（产生 4 牛·米的"刹车"力）
```

**特点**：
- ✅ **kd 越大**：阻尼越大，运动越平滑，但反应变慢
- ✅ **kd 太小**：关节会"震荡"，在目标位置来回摆动
- ⚠️ **kd 太大**：关节反应太慢，像在"泥浆"中移动

#### 3. 组合效果

**理想情况**：
- **kp 适中**：关节能快速到达目标位置
- **kd 适中**：关节能平滑停止，不震荡

**实际效果**：
```
目标位置：0.5 弧度
当前位置：0.3 弧度（正在以 1.0 弧度/秒 的速度移动）

如果 kp = 100, kd = 2：
位置力矩 = 100 × (0.5 - 0.3) = 20 N·m  （拉向目标）
速度力矩 = 2 × (0 - 1.0) = -2 N·m        （减速）
总力矩 = 20 - 2 = 18 N·m                  （既拉向目标，又减速）
```

---

## 第三部分：代码中的 PD 控制器使用

### 📖 方式 1：通过 DDS 发送命令（实时控制）

**位置**：`unitree_sdk2_python/unitree_sdk2py/test/lowlevel/lowlevel_control.py`

```python
from unitree_sdk2py.core.channel import ChannelPublisher, ChannelFactoryInitialize
from unitree_sdk2py.idl.default import unitree_go_msg_dds__LowCmd_
from unitree_sdk2py.utils.crc import CRC

# 初始化 DDS
ChannelFactoryInitialize(1)
pub = ChannelPublisher("lowcmd", LowCmd_)
pub.Init()
crc = CRC()

# 创建控制命令
cmd = unitree_go_msg_dds__LowCmd_()

# 设置关节 0 的位置控制（PD 控制）
cmd.motor_cmd[0].mode = 0x01  # 位置控制模式
cmd.motor_cmd[0].q = 0.5      # 目标位置（弧度）
cmd.motor_cmd[0].kp = 10     # 比例增益（P 控制）
cmd.motor_cmd[0].dq = 0.0    # 目标速度（弧度/秒）
cmd.motor_cmd[0].kd = 1      # 微分增益（D 控制）
cmd.motor_cmd[0].tau = 0     # 前馈力矩（可选）

# 计算 CRC 并发送
cmd.crc = crc.Crc(cmd)
pub.Write(cmd)
```

**参数说明**：
- `q`：目标位置（弧度）
- `kp`：比例增益（P 控制强度）
- `dq`：目标速度（弧度/秒）
- `kd`：微分增益（D 控制强度）
- `tau`：前馈力矩（直接施加的力矩，可选）

---

### 📖 方式 2：在机器人配置中设置（仿真环境）

**位置**：`robots/unitree.py`

```python
from isaaclab.actuators import ImplicitActuatorCfg

# 配置手臂关节的 PD 参数
actuators={
    "arms": ImplicitActuatorCfg(
        joint_names_expr=[
            ".*_shoulder_.*_joint",
            ".*_elbow_joint",
            ".*_wrist_.*_joint"
        ],
        stiffness={  # kp（比例增益）
            ".*_shoulder_.*_joint": 25.0,   # 肩关节：kp = 25
            ".*_elbow_joint": 50.0,         # 肘关节：kp = 50
            ".*_wrist_.*_joint": 40.0,      # 腕关节：kp = 40
        },
        damping={    # kd（微分增益）
            ".*_shoulder_.*_joint": 2.0,   # 肩关节：kd = 2
            ".*_elbow_joint": 2.0,          # 肘关节：kd = 2
            ".*_wrist_.*_joint": 2.0,       # 腕关节：kd = 2
        },
    ),
}
```

**说明**：
- `stiffness` = `kp`（比例增益）
- `damping` = `kd`（微分增益）
- 这些值在仿真环境中自动应用

---

### 📖 方式 3：在 VLM 控制器中使用

**位置**：`vlm_controller_example.py`

```python
class VLMController:
    def __init__(self):
        # 默认 PD 参数
        self.default_kp = 100.0  # 位置增益
        self.default_kd = 2.0    # 速度增益
    
    def send_command(self, vlm_response):
        """通过 DDS 发送控制命令"""
        cmd = unitree_hg_msg_dds__LowCmd_()
        
        # 设置左臂关节（15-21）
        left_arm = vlm_response["left_arm"]
        for i, angle in enumerate(left_arm):
            joint_idx = 15 + i
            cmd.motor_cmd[joint_idx].q = angle      # 目标位置
            cmd.motor_cmd[joint_idx].kp = self.default_kp  # P 控制
            cmd.motor_cmd[joint_idx].dq = 0.0        # 目标速度
            cmd.motor_cmd[joint_idx].kd = self.default_kd  # D 控制
        
        # 发送命令
        self.cmd_publisher.Write(cmd)
```

---

## 第四部分：如何选择合适的 kp 和 kd？

### 📊 参数选择指南

#### 1. 根据关节类型选择

| 关节类型 | kp 范围 | kd 范围 | 说明 |
|---------|---------|---------|------|
| **腿部大关节**（髋、膝） | 150-200 | 5-10 | 需要大力，高刚度 |
| **腿部小关节**（踝） | 20-50 | 2-5 | 需要灵活，中等刚度 |
| **手臂大关节**（肩） | 25-50 | 2-3 | 需要精确，中等刚度 |
| **手臂小关节**（肘、腕） | 40-50 | 2-3 | 需要精确，中等刚度 |
| **手指关节** | 100-200 | 10-20 | 需要快速响应 |

#### 2. 根据任务选择

**高精度任务**（如抓取）：
```python
kp = 100.0  # 高刚度，快速到达目标
kd = 2.0    # 中等阻尼，平滑停止
```

**快速移动任务**（如行走）：
```python
kp = 50.0   # 中等刚度，允许一定误差
kd = 5.0    # 高阻尼，防止震荡
```

**柔顺任务**（如接触物体）：
```python
kp = 20.0   # 低刚度，允许变形
kd = 2.0    # 中等阻尼，保持稳定
```

#### 3. 调参技巧

**步骤 1：先调 kp**
```python
# 从小的 kp 开始
kp = 10.0
kd = 0.0  # 先不用 D 控制

# 观察关节是否能到达目标位置
# 如果太慢，逐渐增大 kp
kp = 20.0
kp = 50.0
kp = 100.0
```

**步骤 2：再调 kd**
```python
# kp 确定后，添加 kd
kp = 100.0  # 固定 kp
kd = 0.5    # 从小开始

# 观察关节是否震荡
# 如果震荡，逐渐增大 kd
kd = 1.0
kd = 2.0
kd = 5.0
```

**步骤 3：微调**
```python
# 如果关节"冲过头"：增大 kd
kd = 3.0

# 如果关节反应太慢：减小 kd
kd = 1.5

# 如果关节到不了目标：增大 kp
kp = 120.0
```

---

## 第五部分：实际使用示例

### 💡 示例 1：控制单个关节

```python
from unitree_sdk2py.core.channel import ChannelPublisher, ChannelFactoryInitialize
from unitree_sdk2py.idl.default import unitree_hg_msg_dds__LowCmd_
from unitree_sdk2py.utils.crc import CRC
import time

# 初始化
ChannelFactoryInitialize(1)
publisher = ChannelPublisher("rt/lowcmd", LowCmd_)
publisher.Init()
crc = CRC()

# 创建命令
cmd = unitree_hg_msg_dds__LowCmd_()

# 设置左肩关节（关节 15）到 0.5 弧度
joint_idx = 15
cmd.motor_cmd[joint_idx].mode = 0x01  # 位置控制
cmd.motor_cmd[joint_idx].q = 0.5     # 目标位置
cmd.motor_cmd[joint_idx].kp = 100.0  # P 控制
cmd.motor_cmd[joint_idx].dq = 0.0    # 目标速度
cmd.motor_cmd[joint_idx].kd = 2.0    # D 控制
cmd.motor_cmd[joint_idx].tau = 0.0   # 前馈力矩

# 发送命令
cmd.crc = crc.Crc(cmd)
publisher.Write(cmd)
```

### 💡 示例 2：控制多个关节

```python
# 控制左臂所有关节（15-21）
left_arm_targets = [0.5, 0.3, 0.2, 0.1, 0.0, 0.0, 0.0]  # 7 个关节的目标位置

for i, target_angle in enumerate(left_arm_targets):
    joint_idx = 15 + i
    cmd.motor_cmd[joint_idx].mode = 0x01
    cmd.motor_cmd[joint_idx].q = target_angle
    cmd.motor_cmd[joint_idx].kp = 100.0
    cmd.motor_cmd[joint_idx].dq = 0.0
    cmd.motor_cmd[joint_idx].kd = 2.0
    cmd.motor_cmd[joint_idx].tau = 0.0

cmd.crc = crc.Crc(cmd)
publisher.Write(cmd)
```

### 💡 示例 3：平滑移动（轨迹跟踪）

```python
import numpy as np

# 从当前位置平滑移动到目标位置
current_angle = 0.0
target_angle = 0.5
duration = 2.0  # 2 秒
steps = 100     # 100 步

for step in range(steps):
    # 计算当前目标（线性插值）
    t = step / steps
    current_target = current_angle + (target_angle - current_angle) * t
    
    # 计算目标速度（用于平滑）
    if step > 0:
        target_velocity = (current_target - prev_target) / (duration / steps)
    else:
        target_velocity = 0.0
    
    # 设置命令
    cmd.motor_cmd[joint_idx].q = current_target
    cmd.motor_cmd[joint_idx].dq = target_velocity
    cmd.motor_cmd[joint_idx].kp = 100.0
    cmd.motor_cmd[joint_idx].kd = 2.0
    
    # 发送命令
    cmd.crc = crc.Crc(cmd)
    publisher.Write(cmd)
    
    prev_target = current_target
    time.sleep(duration / steps)
```

---

## 第六部分：常见问题与调试

### ❓ 问题 1：关节震荡（来回摆动）

**原因**：kd 太小，无法抑制震荡

**解决**：
```python
# 增大 kd
kd = 2.0  # 原来
kd = 5.0  # 增大
```

### ❓ 问题 2：关节反应太慢

**原因**：kp 太小或 kd 太大

**解决**：
```python
# 增大 kp 或减小 kd
kp = 50.0  # 原来
kp = 100.0  # 增大

kd = 5.0   # 原来
kd = 2.0   # 减小
```

### ❓ 问题 3：关节到不了目标位置

**原因**：kp 太小，或者有外力干扰

**解决**：
```python
# 增大 kp
kp = 50.0   # 原来
kp = 200.0  # 增大

# 或者添加前馈力矩
tau = 5.0  # 直接施加力矩
```

### ❓ 问题 4：关节"冲过头"

**原因**：kd 太小，无法及时减速

**解决**：
```python
# 增大 kd
kd = 1.0   # 原来
kd = 5.0   # 增大
```

---

## 第七部分：代码中的实际值参考

### 📋 项目中使用的典型值

#### G1 机器人（29 自由度）

**腿部关节**：
```python
kp = 150-200  # 高刚度
kd = 5.0      # 中等阻尼
```

**手臂关节**：
```python
kp = 25-50    # 中等刚度
kd = 2.0      # 低阻尼
```

**手指关节**：
```python
kp = 100.0    # 高刚度
kd = 10.0     # 高阻尼
```

#### H1-2 机器人（27 自由度）

**腿部关节**：
```python
kp = 150-200  # 高刚度
kd = 5.0      # 中等阻尼
```

**手臂关节**：
```python
kp = 50-100   # 中等刚度
kd = 1.0-2.0  # 低阻尼
```

---

## 第八部分：总结

### ✅ 关键要点

1. **PD 控制器** = 比例控制（P）+ 微分控制（D）
   - **P 控制**：根据位置误差产生"拉回"力
   - **D 控制**：根据速度误差产生"刹车"力

2. **参数选择**：
   - **kp**：控制"硬度"，越大越硬
   - **kd**：控制"阻尼"，越大越平滑

3. **调参顺序**：
   - 先调 kp（让关节能到达目标）
   - 再调 kd（让关节不震荡）

4. **典型值**：
   - 大关节：kp = 100-200, kd = 5-10
   - 小关节：kp = 20-50, kd = 2-5

5. **使用方式**：
   - **DDS 控制**：实时发送 `kp` 和 `kd`
   - **仿真配置**：在 `robots/unitree.py` 中设置 `stiffness` 和 `damping`

---

## 📚 相关文件

- **DDS 控制示例**：`unitree_sdk2_python/unitree_sdk2py/test/lowlevel/lowlevel_control.py`
- **机器人配置**：`robots/unitree.py`
- **VLM 控制器**：`vlm_controller_example.py`
- **控制方法指南**：`ROBOT_CONTROL_METHODS.md`

