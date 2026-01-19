# 🤖 机器人控制架构与最佳实践指南

## 目录

1. [机器人原生的不同控制方式（从高频率到低频率）](#第一部分机器人原生的不同控制方式)
2. [程序调用时如何保证动作平滑且满足平衡要求](#第二部分程序调用时的平滑性与平衡性要求)
3. [PD控制器直接用模型调用时需要考虑的问题](#第三部分pd控制器与模型结合使用)

---

## 第一部分：机器人原生的不同控制方式

### 📊 控制层次架构（从高频率到低频率）

```
┌─────────────────────────────────────────────────────────┐
│  高层控制 (High-Level Control)                        │
│  频率: 10-50 Hz                                        │
│  内容: 速度命令、姿态控制、轨迹跟踪、特殊动作          │
└─────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────┐
│  主控制循环 (Main Control Loop)                        │
│  频率: 100 Hz (默认)                                    │
│  内容: 仿真环境步进、动作执行、观测获取                 │
└─────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────┐
│  低层控制 (Low-Level Control)                          │
│  频率: 500 Hz (固定)                                    │
│  内容: PD控制器、关节力矩计算、电机驱动                 │
└─────────────────────────────────────────────────────────┘
```

---

### 1. 低层控制（Low-Level Control）- 500 Hz ⚡

**频率**：500 Hz（每 2 毫秒执行一次）  
**位置**：`layeredcontrol/robot_control_system.py`  
**用途**：直接控制关节，执行 PD 控制

#### 特点

- ✅ **最高频率**：确保关节控制的实时性和稳定性
- ✅ **直接控制**：直接设置关节位置、速度、力矩
- ✅ **PD 控制**：使用 kp 和 kd 参数进行位置和速度控制
- ✅ **固定频率**：不能调整，必须保持 500 Hz

#### 控制接口

```python
# 通过 DDS 发送低层命令
cmd.motor_cmd[joint_idx].mode = 0x01      # 位置控制模式
cmd.motor_cmd[joint_idx].q = 0.5          # 目标位置（弧度）
cmd.motor_cmd[joint_idx].kp = 100.0       # 比例增益
cmd.motor_cmd[joint_idx].dq = 0.0         # 目标速度
cmd.motor_cmd[joint_idx].kd = 2.0         # 微分增益
cmd.motor_cmd[joint_idx].tau = 0.0        # 前馈力矩
```

#### 适用场景

- 精确的关节位置控制
- 需要高频率反馈的控制任务
- 底层安全保护

---

### 2. 主控制循环（Main Control Loop）- 100 Hz 🔄

**频率**：100 Hz（默认，可通过 `--step_hz` 调整）  
**位置**：`sim_main.py`  
**用途**：仿真环境的主循环，协调所有控制模块

#### 特点

- ✅ **可调整频率**：可以通过 `--step_hz` 参数调整（50-200 Hz）
- ✅ **协调作用**：整合动作提供者、环境步进、观测获取
- ✅ **平衡性能**：在实时性和计算负担之间平衡

#### 控制接口

```python
# 通过命令行参数调整
python sim_main.py --step_hz 100  # 默认 100 Hz
python sim_main.py --step_hz 50   # 降低到 50 Hz（更省资源）
python sim_main.py --step_hz 200  # 提高到 200 Hz（更快反应）
```

#### 适用场景

- 仿真环境控制
- RL 策略执行
- 多模块协调

---

### 3. DDS 通信层 - 100 Hz 📡

**频率**：100 Hz（默认，可自定义）  
**位置**：`dds/dds_master.py`  
**用途**：机器人状态发布和命令接收

#### 特点

- ✅ **实时通信**：通过 DDS 协议进行实时数据交换
- ✅ **可自定义频率**：可以为不同消息类型设置不同频率
- ✅ **多通道支持**：支持多个控制通道（机器人、夹爪、手等）

#### 控制接口

```python
from dds.dds_master import dds_manager

# 设置特定对象的发布频率
dds_manager.set_publish_rate("robot_state", 50)   # 50 Hz
dds_manager.set_publish_rate("gripper_state", 100) # 100 Hz
```

#### 适用场景

- 外部程序控制机器人
- 多进程通信
- 实时状态监控

---

### 4. 键盘控制 - 50 Hz ⌨️

**频率**：50 Hz（`time.sleep(0.02)`）  
**位置**：`send_commands_keyboard.py`  
**用途**：人类通过键盘输入控制命令

#### 特点

- ✅ **人类友好**：适合人类操作的反应速度
- ✅ **低通滤波**：使用 `LowPassFilter` 平滑输入
- ✅ **加速度限制**：防止突然变化

#### 控制接口

```python
# 键盘控制循环
while True:
    # 更新控制参数（50 Hz）
    update_control_params()
    time.sleep(0.02)  # 50 Hz
```

#### 适用场景

- 手动遥操作
- 演示和测试
- 交互式控制

---

### 5. 高层控制（High-Level Control）- 10-50 Hz 🎯

**频率**：10-50 Hz（根据任务类型）  
**位置**：`unitree_sdk2_python/unitree_sdk2py/g1/loco/`  
**用途**：高层命令（速度、姿态、轨迹）

#### 特点

- ✅ **抽象控制**：不需要直接控制关节
- ✅ **任务级控制**：控制速度、姿态、轨迹等
- ✅ **内置平衡**：机器人内部处理平衡和稳定性

#### 控制接口

```python
from unitree_sdk2py.g1.loco import LocoClient

client = LocoClient()

# 速度控制
client.SetVelocity(vx=0.5, vy=0.0, omega=0.0, duration=1.0)

# 姿态控制
client.BalanceStand(balance_mode=1)

# 轨迹跟踪
client.TrajectoryFollow(path=[...])
```

#### 适用场景

- 移动控制（前进、后退、转向）
- 姿态控制（站立、下蹲）
- 轨迹跟踪
- 特殊动作（挥手、握手）

---

### 6. AI/VLM 推理 - 10-20 Hz 🧠

**频率**：10-20 Hz（推荐）  
**位置**：`vlm_controller_example.py`  
**用途**：AI 模型推理生成控制命令

#### 特点

- ✅ **低频率**：AI 推理计算量大，不需要太高频率
- ✅ **高层决策**：生成高层命令或关节目标位置
- ✅ **可调整**：根据模型复杂度调整频率

#### 控制接口

```python
# VLM 控制循环
def run(self, frequency: float = 10.0):
    dt = 1.0 / frequency  # 例如：10 Hz = 0.1 秒
    while True:
        # 1. 获取图像
        image = get_camera_image()
        
        # 2. AI 推理
        action = vlm_inference(image, task_description)
        
        # 3. 发送命令
        send_command(action)
        
        time.sleep(dt)
```

#### 适用场景

- 视觉语言模型控制
- 强化学习策略
- 高层任务规划

---

## 第二部分：程序调用时的平滑性与平衡性要求

### 🎯 保证动作平滑的关键技术

#### 1. 低通滤波器（Low-Pass Filter）

**作用**：平滑突然的命令变化，防止抖动

**实现**：`send_commands_keyboard.py`

```python
class LowPassFilter:
    def __init__(self, alpha=0.15):
        self.alpha = alpha  # 滤波系数（0-1，越小越平滑）
        self._value = 0.0
        self._last_value = 0.0

    def update(self, new_value, max_accel=1.5):
        # 限制加速度
        delta = new_value - self._last_value
        delta = np.clip(delta, -max_accel, max_accel)
        
        # 低通滤波
        filtered = self.alpha * (self._last_value + delta) + (1 - self.alpha) * self._value
        self._last_value = filtered
        self._value = filtered
        return self._value
```

**使用示例**：

```python
# 创建滤波器
filter = LowPassFilter(alpha=0.3)  # alpha 越小，越平滑

# 每次更新时使用滤波器
target_velocity = 0.5
smooth_velocity = filter.update(target_velocity, max_accel=1.5)
```

**参数选择**：
- **alpha = 0.1-0.3**：非常平滑，适合精细操作
- **alpha = 0.3-0.5**：中等平滑，平衡响应和平滑
- **alpha > 0.5**：响应快，但可能不够平滑

---

#### 2. 轨迹插值（Trajectory Interpolation）

**作用**：在目标位置之间生成平滑的过渡轨迹

**实现**：`send_commands_8bit.py`

```python
# 使用平滑曲线插值
def smooth_interpolation(t):
    """t 在 [0, 1] 之间"""
    # 5 次多项式平滑曲线
    smooth = 6*t**5 - 15*t**4 + 10*t**3
    return smooth

# 从当前位置到目标位置
current_angle = 0.0
target_angle = 0.5
duration = 2.0  # 2 秒
steps = 100

for step in range(steps):
    t = step / steps
    # 使用平滑插值
    current_target = current_angle + (target_angle - current_angle) * smooth_interpolation(t)
    
    # 发送命令
    send_joint_command(current_target)
    time.sleep(duration / steps)
```

**插值方法**：
- **线性插值**：简单但可能不平滑
- **多项式插值**：平滑但计算复杂
- **样条插值**：最平滑但最复杂

---

#### 3. 加速度限制（Acceleration Limiting）

**作用**：限制关节加速度，防止突然变化

**实现**：

```python
def limit_acceleration(current_value, target_value, max_accel, dt):
    """限制加速度"""
    # 计算最大允许变化
    max_delta = max_accel * dt
    
    # 限制变化量
    delta = target_value - current_value
    delta = np.clip(delta, -max_delta, max_delta)
    
    # 返回限制后的值
    return current_value + delta

# 使用示例
current_velocity = 0.0
target_velocity = 1.0
max_accel = 2.0  # 最大加速度 2.0 m/s²
dt = 0.01  # 时间步长 0.01 秒

limited_velocity = limit_acceleration(current_velocity, target_velocity, max_accel, dt)
```

**参数选择**：
- **腿部关节**：max_accel = 5-10 rad/s²
- **手臂关节**：max_accel = 2-5 rad/s²
- **手指关节**：max_accel = 1-2 rad/s²

---

#### 4. 速度限制（Velocity Limiting）

**作用**：限制关节速度，防止过快运动

**实现**：

```python
def limit_velocity(target_velocity, max_velocity):
    """限制速度"""
    return np.clip(target_velocity, -max_velocity, max_velocity)

# 使用示例
target_velocity = 2.0  # 目标速度
max_velocity = 1.0      # 最大允许速度
limited_velocity = limit_velocity(target_velocity, max_velocity)  # 结果：1.0
```

---

### ⚖️ 保证平衡的关键技术

#### 1. 平衡模式（Balance Mode）

**作用**：机器人内部自动维持平衡

**实现**：

```python
from unitree_sdk2py.g1.loco import LocoClient

client = LocoClient()

# 启用平衡模式
client.BalanceStand(balance_mode=1)  # 1 = 启用，0 = 禁用
```

**平衡模式类型**：
- **模式 0**：禁用平衡，需要手动控制
- **模式 1**：启用平衡，自动维持姿态
- **模式 2**：高级平衡，适应复杂地形

---

#### 2. 重心控制（Center of Mass Control）

**作用**：通过调整重心位置维持平衡

**实现**：

```python
# 在 Wholebody 任务中，通过调整高度和姿态
command = [x_vel, y_vel, yaw_vel, height]

# height 参数影响重心高度
# 较低的高度 = 更稳定
# 较高的高度 = 更灵活但可能不稳定
```

---

#### 3. 支撑多边形（Support Polygon）

**作用**：确保重心在支撑范围内

**实现**：

```python
def check_balance(com_position, foot_positions):
    """检查重心是否在支撑多边形内"""
    # 计算支撑多边形
    support_polygon = compute_convex_hull(foot_positions)
    
    # 检查重心是否在多边形内
    if point_in_polygon(com_position, support_polygon):
        return True  # 平衡
    else:
        return False  # 可能失衡
```

---

### 📋 程序调用的最佳实践

#### 1. 频率同步

```python
# 确保控制频率与系统频率匹配
control_frequency = 100  # Hz
dt = 1.0 / control_frequency

while True:
    # 执行控制
    execute_control()
    
    # 精确的时间控制
    time.sleep(dt)
```

#### 2. 命令缓冲

```python
# 使用命令缓冲区平滑过渡
command_buffer = []

def add_command(new_command):
    command_buffer.append(new_command)
    # 保持缓冲区大小
    if len(command_buffer) > 10:
        command_buffer.pop(0)

def get_smooth_command():
    # 使用缓冲区中的命令进行插值
    return interpolate_commands(command_buffer)
```

#### 3. 状态检查

```python
# 在执行新命令前检查当前状态
def safe_execute_command(new_command):
    # 1. 检查关节限制
    if not check_joint_limits(new_command):
        return False
    
    # 2. 检查速度限制
    if not check_velocity_limits(new_command):
        return False
    
    # 3. 检查平衡状态
    if not check_balance():
        return False
    
    # 4. 执行命令
    execute_command(new_command)
    return True
```

---

## 第三部分：PD控制器与模型结合使用

### 🤖 模型输出与PD控制的集成

#### 1. 模型输出格式

**模型通常输出**：
- 关节目标位置（相对增量或绝对位置）
- 关节目标速度（可选）
- 高层命令（速度、姿态等）

**PD控制器需要**：
- 目标位置 `q`
- 比例增益 `kp`
- 目标速度 `dq`
- 微分增益 `kd`
- 前馈力矩 `tau`（可选）

---

#### 2. 模型输出到PD命令的转换

```python
def model_output_to_pd_command(model_output, current_state):
    """将模型输出转换为PD控制命令"""
    cmd = LowCmd_()
    
    # 模型输出可能是：
    # 1. 相对增量（需要加到当前位置）
    # 2. 绝对位置（直接使用）
    # 3. 归一化值（需要反归一化）
    
    for i, joint_output in enumerate(model_output):
        # 假设模型输出是相对增量
        target_position = current_state.joint_pos[i] + joint_output
        
        # 设置PD参数
        cmd.motor_cmd[i].q = target_position
        cmd.motor_cmd[i].kp = 100.0  # 从模型或配置获取
        cmd.motor_cmd[i].dq = 0.0    # 从模型或计算得出
        cmd.motor_cmd[i].kd = 2.0    # 从模型或配置获取
        cmd.motor_cmd[i].tau = 0.0   # 可选：前馈力矩
    
    return cmd
```

---

### ⚠️ 需要考虑的关键问题

#### 1. 频率同步问题

**问题**：模型推理频率（10-20 Hz）与PD控制频率（500 Hz）不匹配

**解决方案**：

```python
class ModelPDController:
    def __init__(self):
        self.model_frequency = 10  # Hz
        self.pd_frequency = 500     # Hz
        self.model_dt = 1.0 / self.model_frequency
        self.pd_dt = 1.0 / self.pd_frequency
        
        # 命令插值缓冲区
        self.target_positions = None
        self.current_positions = None
        self.interpolation_steps = int(self.model_frequency / self.pd_frequency)
    
    def update(self):
        # 每 50 个PD周期（500/10=50）更新一次模型输出
        if self.step_count % self.interpolation_steps == 0:
            # 获取新的模型输出
            new_targets = self.model_inference()
            
            # 更新插值起点和终点
            self.current_positions = self.get_current_positions()
            self.target_positions = new_targets
        
        # 每次PD周期进行插值
        interpolated = self.interpolate(
            self.current_positions,
            self.target_positions,
            (self.step_count % self.interpolation_steps) / self.interpolation_steps
        )
        
        # 生成PD命令
        return self.generate_pd_command(interpolated)
```

---

#### 2. 动作平滑性问题

**问题**：模型输出可能突变，导致关节抖动

**解决方案**：

```python
class SmoothModelPDController:
    def __init__(self):
        # 低通滤波器
        self.filters = [LowPassFilter(alpha=0.3) for _ in range(num_joints)]
        
        # 加速度限制
        self.max_accel = [5.0] * num_joints  # rad/s²
    
    def smooth_model_output(self, model_output, dt):
        """平滑模型输出"""
        smoothed = []
        for i, output in enumerate(model_output):
            # 方法1：低通滤波
            filtered = self.filters[i].update(output, max_accel=self.max_accel[i])
            
            # 方法2：加速度限制
            current = self.get_current_position(i)
            max_delta = self.max_accel[i] * dt
            delta = np.clip(filtered - current, -max_delta, max_delta)
            
            smoothed.append(current + delta)
        
        return smoothed
```

---

#### 3. PD参数选择问题

**问题**：如何为模型输出选择合适的kp和kd？

**解决方案**：

```python
class AdaptivePDController:
    def __init__(self):
        # 基础PD参数
        self.base_kp = 100.0
        self.base_kd = 2.0
        
        # 根据关节类型调整
        self.kp_map = {
            'leg': 150.0,
            'arm': 50.0,
            'hand': 100.0,
        }
        self.kd_map = {
            'leg': 5.0,
            'arm': 2.0,
            'hand': 10.0,
        }
    
    def get_pd_params(self, joint_name, model_confidence=None):
        """根据关节名称和模型置信度获取PD参数"""
        # 基础参数
        joint_type = self.get_joint_type(joint_name)
        kp = self.kp_map.get(joint_type, self.base_kp)
        kd = self.kd_map.get(joint_type, self.base_kd)
        
        # 根据模型置信度调整（可选）
        if model_confidence is not None:
            # 置信度低时，降低kp（更柔顺）
            kp *= model_confidence
            kd *= model_confidence
        
        return kp, kd
```

---

#### 4. 稳定性问题

**问题**：模型输出可能导致机器人不稳定

**解决方案**：

```python
class StableModelPDController:
    def __init__(self):
        # 稳定性检查
        self.max_joint_velocity = 5.0  # rad/s
        self.max_joint_acceleration = 10.0  # rad/s²
        self.balance_threshold = 0.1  # 重心偏移阈值
    
    def check_stability(self, command, current_state):
        """检查命令是否会导致不稳定"""
        # 1. 检查关节速度
        for i in range(len(command.joint_positions)):
            velocity = abs(command.joint_positions[i] - current_state.joint_pos[i]) / dt
            if velocity > self.max_joint_velocity:
                return False, f"Joint {i} velocity too high: {velocity}"
        
        # 2. 检查关节加速度
        acceleration = abs(velocity - current_state.joint_vel[i]) / dt
        if acceleration > self.max_joint_acceleration:
            return False, f"Joint {i} acceleration too high: {acceleration}"
        
        # 3. 检查平衡（如果是Wholebody任务）
        if self.is_wholebody_task():
            com_offset = self.compute_com_offset(command)
            if abs(com_offset) > self.balance_threshold:
                return False, f"COM offset too large: {com_offset}"
        
        return True, "OK"
    
    def safe_execute(self, model_output):
        """安全执行模型输出"""
        command = self.model_output_to_pd_command(model_output)
        is_stable, message = self.check_stability(command, self.current_state)
        
        if is_stable:
            self.execute_command(command)
        else:
            print(f"Warning: {message}, using safe fallback")
            self.execute_safe_fallback()
```

---

#### 5. 关节限制问题

**问题**：模型输出可能超出关节物理限制

**解决方案**：

```python
class LimitedModelPDController:
    def __init__(self):
        # 关节限制
        self.joint_limits = {
            'min_pos': [-3.14] * num_joints,  # 最小位置
            'max_pos': [3.14] * num_joints,   # 最大位置
            'max_vel': [5.0] * num_joints,    # 最大速度
            'max_torque': [100.0] * num_joints,  # 最大力矩
        }
    
    def clamp_command(self, command):
        """限制命令在安全范围内"""
        for i in range(len(command.joint_positions)):
            # 限制位置
            command.joint_positions[i] = np.clip(
                command.joint_positions[i],
                self.joint_limits['min_pos'][i],
                self.joint_limits['max_pos'][i]
            )
            
            # 限制速度
            command.joint_velocities[i] = np.clip(
                command.joint_velocities[i],
                -self.joint_limits['max_vel'][i],
                self.joint_limits['max_vel'][i]
            )
        
        return command
```

---

### 📋 模型+PD控制的最佳实践

#### 1. 完整的模型PD控制器示例

```python
class ModelPDController:
    def __init__(self, model, pd_config):
        self.model = model
        self.pd_config = pd_config
        
        # 频率控制
        self.model_frequency = 10  # Hz
        self.pd_frequency = 500    # Hz
        self.model_dt = 1.0 / self.model_frequency
        
        # 平滑处理
        self.filters = [LowPassFilter(alpha=0.3) for _ in range(num_joints)]
        
        # 状态跟踪
        self.current_positions = None
        self.target_positions = None
        self.step_count = 0
    
    def step(self, observations):
        """每步执行"""
        # 1. 模型推理（每 50 个PD周期执行一次）
        if self.step_count % (self.pd_frequency // self.model_frequency) == 0:
            model_output = self.model.inference(observations)
            self.target_positions = self.process_model_output(model_output)
        
        # 2. 平滑处理
        if self.current_positions is None:
            self.current_positions = self.get_current_positions()
        
        smoothed = self.smooth_transition(
            self.current_positions,
            self.target_positions
        )
        
        # 3. 生成PD命令
        pd_command = self.generate_pd_command(smoothed)
        
        # 4. 稳定性检查
        if self.check_stability(pd_command):
            self.execute_command(pd_command)
            self.current_positions = smoothed
        else:
            self.execute_safe_fallback()
        
        self.step_count += 1
    
    def process_model_output(self, model_output):
        """处理模型输出"""
        # 1. 反归一化（如果模型输出是归一化的）
        positions = self.denormalize(model_output)
        
        # 2. 限制在关节范围内
        positions = self.clamp_to_limits(positions)
        
        return positions
    
    def smooth_transition(self, current, target):
        """平滑过渡"""
        smoothed = []
        for i in range(len(current)):
            # 使用低通滤波器
            filtered = self.filters[i].update(
                target[i],
                max_accel=self.pd_config.max_accel[i]
            )
            smoothed.append(filtered)
        return smoothed
    
    def generate_pd_command(self, positions):
        """生成PD命令"""
        cmd = LowCmd_()
        for i, pos in enumerate(positions):
            cmd.motor_cmd[i].q = pos
            cmd.motor_cmd[i].kp = self.pd_config.get_kp(i)
            cmd.motor_cmd[i].dq = 0.0  # 或从模型获取
            cmd.motor_cmd[i].kd = self.pd_config.get_kd(i)
        return cmd
```

---

#### 2. 配置示例

```python
# PD配置
pd_config = {
    'kp': {
        'leg': 150.0,
        'arm': 50.0,
        'hand': 100.0,
    },
    'kd': {
        'leg': 5.0,
        'arm': 2.0,
        'hand': 10.0,
    },
    'max_accel': {
        'leg': 10.0,
        'arm': 5.0,
        'hand': 2.0,
    },
    'max_vel': {
        'leg': 5.0,
        'arm': 3.0,
        'hand': 2.0,
    },
}
```

---

## 总结

### ✅ 关键要点

1. **控制层次**：
   - 低层控制（500 Hz）：直接关节控制
   - 主控制循环（100 Hz）：协调控制
   - 高层控制（10-50 Hz）：任务级控制

2. **平滑性保证**：
   - 低通滤波器
   - 轨迹插值
   - 加速度限制
   - 速度限制

3. **平衡性保证**：
   - 平衡模式
   - 重心控制
   - 支撑多边形检查

4. **模型+PD集成**：
   - 频率同步
   - 动作平滑
   - PD参数选择
   - 稳定性检查
   - 关节限制

---

## 📚 相关文档

- **PD控制器详解**：`PD_CONTROLLER_GUIDE.md`
- **控制频率说明**：`ONNX_AND_FREQUENCY_GUIDE.md`
- **控制方法总览**：`ROBOT_CONTROL_METHODS.md`

