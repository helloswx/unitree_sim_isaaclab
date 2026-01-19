# 🤖 机器人控制方式详解

## 📋 控制方式概览

机器人可以通过以下方式控制：

| 控制方式 | 适用任务 | 控制内容 | 实现方式 |
|---------|---------|---------|---------|
| **1. DDS 通信** | Joint/Wholebody | 关节位置/速度/力矩 | `rt/lowcmd` 通道 |
| **2. 键盘控制** | Wholebody | 移动命令（x_vel, y_vel, yaw_vel, height） | `rt/run_command/cmd` 通道 |
| **3. 策略模型** | Joint/Wholebody | 自动执行任务 | ONNX 模型推理 |
| **4. Replay 数据** | Joint/Wholebody | 回放预录制的动作 | 文件读取 |
| **5. 外部程序** | Joint/Wholebody | 自定义控制逻辑 | DDS 或共享内存 |

---

## 🔌 方式 1: DDS 通信（最灵活）

### 控制通道

#### A. 机器人身体控制：`rt/lowcmd`

**通道名称：** `rt/lowcmd`  
**消息类型：** `LowCmd_`  
**控制内容：** 29 个关节的位置、速度、力矩、增益

**命令格式：**
```python
{
    "mode_pr": int,           # 模式
    "mode_machine": int,      # 机器模式
    "motor_cmd": {
        "positions": [29个关节位置],    # 弧度
        "velocities": [29个关节速度],   # 弧度/秒
        "torques": [29个关节力矩],      # N·m
        "kp": [29个位置增益],
        "kd": [29个速度增益]
    }
}
```

**关节顺序（G1）：**
- 0-14: 腿部关节（15个）
- 15-28: 手臂关节（14个）
  - 15-21: 左臂（7个）
  - 22-28: 右臂（7个）

#### B. Wholebody 移动控制：`rt/run_command/cmd`

**通道名称：** `rt/run_command/cmd`  
**消息类型：** `String_`  
**控制内容：** 移动命令（仅 Wholebody 任务）

**命令格式：**
```python
"[x_vel, y_vel, yaw_vel, height]"
# 例如: "[0.5, 0.0, 0.0, 0.8]"
```

**参数说明：**
- `x_vel`: 前进速度 (-0.6 到 1.0 m/s)
- `y_vel`: 侧向速度 (-0.5 到 0.5 m/s)
- `yaw_vel`: 旋转速度 (-1.57 到 1.57 rad/s)
- `height`: 高度 (0.3 到 0.8 m)

#### C. 夹爪控制：`rt/unitree_actuator/cmd`

**通道名称：** `rt/unitree_actuator/cmd`  
**消息类型：** `MotorCmds_`  
**控制内容：** 夹爪位置/速度/力矩

**命令格式：**
```python
{
    "cmds": [
        {
            "q": float,    # 位置（归一化 0-5.6）
            "dq": float,   # 速度
            "tau": float,  # 力矩
            "kp": float,   # 位置增益
            "kd": float    # 速度增益
        }
    ]
}
```

#### D. 三指灵巧手控制：`rt/dex3/cmd`

**通道名称：** `rt/dex3/cmd`  
**消息类型：** `MotorCmds_`  
**控制内容：** 左右手各 7 个手指关节

#### E. Inspire 手控制：`rt/inspire/cmd`

**通道名称：** `rt/inspire/cmd`  
**消息类型：** `MotorCmds_`  
**控制内容：** 左右手各 6 个手指关节（共 12 个）

---

## 📡 方式 2: 共享内存（内部通信）

仿真内部使用共享内存进行快速通信：

- **`isaac_robot_state`**: 读取机器人状态
- **`dds_robot_cmd`**: 写入机器人命令
- **`isaac_gripper_state`**: 读取夹爪状态
- **`dds_gripper_cmd`**: 写入夹爪命令

---

## 🎮 方式 3: 键盘控制（示例）

参考 `send_commands_keyboard.py`，通过 DDS 发送移动命令。

---

## 🧠 方式 4: 策略模型

使用训练好的 ONNX 模型自动生成动作。

---

## 🔄 方式 5: Replay 数据

从文件读取预录制的动作序列。

---

## 🤖 接入 VLM（视觉语言模型）指南

### 架构设计

```
VLM 程序
    ↓
DDS 通道 (rt/lowcmd, rt/run_command/cmd, rt/unitree_actuator/cmd)
    ↓
仿真环境 (Isaac Sim)
    ↓
相机图像 (通过共享内存或 DDS)
    ↓
VLM 程序 (获取图像)
```

### 方案 A: 创建自定义 Action Provider（推荐）

创建一个新的 `VLMActionProvider`，继承 `ActionProvider`：

```python
# action_provider/action_provider_vlm.py

from action_provider.action_base import ActionProvider
from typing import Optional
import torch
import numpy as np
from PIL import Image
import requests
import base64

class VLMActionProvider(ActionProvider):
    """VLM-based action provider"""
    
    def __init__(self, env, args_cli):
        super().__init__("VLMActionProvider")
        self.env = env
        self.vlm_api_url = args_cli.vlm_api_url  # VLM API 地址
        self._setup_joint_mapping()
        
    def get_action(self, env) -> Optional[torch.Tensor]:
        """Get action from VLM"""
        try:
            # 1. 获取相机图像
            camera_image = self._get_camera_image(env)
            
            # 2. 调用 VLM API
            action_command = self._query_vlm(camera_image)
            
            # 3. 转换为关节角度
            joint_positions = self._parse_vlm_response(action_command)
            
            # 4. 转换为 torch.Tensor
            full_action = self._convert_to_action(joint_positions)
            
            return full_action
            
        except Exception as e:
            print(f"[VLM] Error: {e}")
            return None
    
    def _get_camera_image(self, env):
        """从环境获取相机图像"""
        # 方法1: 从共享内存读取
        # 方法2: 从环境观测获取
        obs = env.get_obs()
        if 'camera_image' in obs:
            return obs['camera_image']
        return None
    
    def _query_vlm(self, image):
        """调用 VLM API"""
        # 将图像编码为 base64
        image_base64 = self._encode_image(image)
        
        # 构建提示词
        prompt = "根据图像，生成机器人控制命令。格式：[left_arm_7_joints, right_arm_7_joints, gripper]"
        
        # 调用 VLM API
        response = requests.post(
            self.vlm_api_url,
            json={
                "image": image_base64,
                "prompt": prompt
            }
        )
        
        return response.json()["action"]
    
    def _parse_vlm_response(self, response):
        """解析 VLM 响应"""
        # 解析 JSON 响应，提取关节角度
        # 返回关节位置列表
        pass
    
    def _convert_to_action(self, joint_positions):
        """转换为动作张量"""
        # 转换为 torch.Tensor 格式
        pass
```

### 方案 B: 通过 DDS 发送命令（更简单）

创建一个独立的 VLM 控制程序，通过 DDS 发送命令：

```python
# vlm_controller.py

from unitree_sdk2py.core.channel import ChannelPublisher, ChannelFactoryInitialize
from unitree_sdk2py.idl.unitree_hg.msg.dds_ import LowCmd_
from unitree_sdk2py.utils.crc import CRC
import numpy as np
import requests
import base64
from PIL import Image
import io

class VLMController:
    def __init__(self):
        # 初始化 DDS
        ChannelFactoryInitialize(1)
        self.publisher = ChannelPublisher("rt/lowcmd", LowCmd_)
        self.publisher.Init()
        self.crc = CRC()
        
        # VLM API 配置
        self.vlm_api_url = "http://localhost:8000/vlm/infer"
        
    def get_camera_image(self):
        """从共享内存或图像服务器获取图像"""
        # 方法1: 从共享内存读取
        # 方法2: 从图像服务器获取（端口 5555）
        # 方法3: 从 DDS 订阅相机数据
        pass
    
    def query_vlm(self, image, task_description):
        """查询 VLM 获取控制命令"""
        # 编码图像
        image_base64 = self._encode_image(image)
        
        # 构建提示词
        prompt = f"""
        任务: {task_description}
        当前图像: [图像]
        
        请生成机器人控制命令：
        - 左臂7个关节角度（弧度）
        - 右臂7个关节角度（弧度）
        - 夹爪开合度（0-1）
        
        返回格式: JSON
        {{
            "left_arm": [7个角度],
            "right_arm": [7个角度],
            "gripper": 0.5
        }}
        """
        
        # 调用 VLM API
        response = requests.post(
            self.vlm_api_url,
            json={
                "image": image_base64,
                "prompt": prompt
            }
        )
        
        return response.json()
    
    def send_command(self, vlm_response):
        """通过 DDS 发送控制命令"""
        cmd = unitree_hg_msg_dds__LowCmd_()
        
        # 设置关节命令
        left_arm = vlm_response["left_arm"]
        right_arm = vlm_response["right_arm"]
        
        # G1 关节顺序：腿部(0-14) + 左臂(15-21) + 右臂(22-28)
        positions = [0.0] * 29
        
        # 设置左臂（关节 15-21）
        for i, angle in enumerate(left_arm):
            positions[15 + i] = angle
            cmd.motor_cmd[15 + i].q = angle
            cmd.motor_cmd[15 + i].kp = 100.0
            cmd.motor_cmd[15 + i].kd = 2.0
        
        # 设置右臂（关节 22-28）
        for i, angle in enumerate(right_arm):
            positions[22 + i] = angle
            cmd.motor_cmd[22 + i].q = angle
            cmd.motor_cmd[22 + i].kp = 100.0
            cmd.motor_cmd[22 + i].kd = 2.0
        
        # 计算 CRC
        cmd.crc = self.crc.Crc(cmd)
        
        # 发布命令
        self.publisher.Write(cmd)
    
    def _encode_image(self, image):
        """将图像编码为 base64"""
        if isinstance(image, np.ndarray):
            image = Image.fromarray(image)
        buffer = io.BytesIO()
        image.save(buffer, format='JPEG')
        return base64.b64encode(buffer.getvalue()).decode()
    
    def run(self):
        """主循环"""
        while True:
            # 1. 获取图像
            image = self.get_camera_image()
            
            # 2. 查询 VLM
            task = "抓取红色木块"
            response = self.query_vlm(image, task)
            
            # 3. 发送命令
            self.send_command(response)
            
            time.sleep(0.02)  # 50Hz
```

### 方案 C: 修改现有 Action Provider

在 `action_provider_dds.py` 中添加 VLM 支持：

```python
# 在 get_action 方法中添加 VLM 分支
def get_action(self, env) -> Optional[torch.Tensor]:
    # 如果启用 VLM
    if self.use_vlm:
        vlm_action = self._get_vlm_action(env)
        if vlm_action is not None:
            return vlm_action
    
    # 否则使用 DDS 命令
    # ... 原有代码
```

---

## 📸 获取相机图像的方法

### 方法 1: 从环境观测获取

```python
obs = env.get_obs()
camera_image = obs['camera_image']  # shape: (480, 640, 3)
```

### 方法 2: 从图像服务器获取

```python
# 图像服务器运行在端口 5555
import zmq
import numpy as np

context = zmq.Context()
socket = context.socket(zmq.SUB)
socket.connect("tcp://localhost:5555")
socket.setsockopt_string(zmq.SUBSCRIBE, "")

# 接收图像
image_data = socket.recv()
image = np.frombuffer(image_data, dtype=np.uint8)
```

### 方法 3: 从共享内存获取

```python
from image_server.shared_memory_utils import MultiImageReader

reader = MultiImageReader()
image_dict = reader.read()  # 包含多个相机的图像
front_camera = image_dict.get('front_camera')
```

---

## 🔧 实现步骤

### 步骤 1: 创建 VLM 控制程序

```bash
# 创建新文件
touch vlm_controller.py
```

### 步骤 2: 安装依赖

```bash
pip install requests pillow numpy
```

### 步骤 3: 实现 VLM 接口

根据你使用的 VLM（如 GPT-4V, Claude, LLaVA 等），实现相应的 API 调用。

### 步骤 4: 运行

```bash
# 终端1: 启动仿真
python sim_main.py --task Isaac-PickPlace-RedBlock-G129-Dex1-Joint ...

# 终端2: 运行 VLM 控制器
python vlm_controller.py
```

---

## 📝 VLM 控制示例代码

创建一个完整的示例文件。

---

## ⏱️ 控制频率总结

### 📊 各控制方式的频率要求

| 控制方式 | 频率 | 代码位置 | 说明 |
|---------|------|---------|------|
| **主控制循环** | **100 Hz** (默认) | `sim_main.py:49` | `--step_hz 100` |
| **低层控制器** | **500 Hz** (固定) | `robot_control_system.py:17` | 机器人底层控制 |
| **键盘控制** | **50 Hz** | `send_commands_keyboard.py:210` | `time.sleep(0.02)` |
| **DDS 发布** | **100 Hz** (默认) | `dds_master.py:40` | 可自定义 |
| **ONNX 推理** | **跟随主循环** | `action_provider_wh_dds.py` | 通常 100 Hz |
| **VLM 控制** | **10-20 Hz** (推荐) | `vlm_controller_example.py` | AI 推理较慢 |

### 🔧 如何调整频率

```bash
# 调整主控制循环频率
python sim_main.py --step_hz 50   # 降低到 50 Hz（更省资源）
python sim_main.py --step_hz 200  # 提高到 200 Hz（更快反应）
```

### 📈 频率与性能

- **实时控制**：≥ 100 Hz（主循环、DDS）
- **人类操作**：50 Hz 足够（键盘控制）
- **AI 推理**：10-20 Hz 足够（VLM、策略模型）
- **底层控制**：≥ 500 Hz（关节控制）

**详细说明请参考：** `ONNX_AND_FREQUENCY_GUIDE.md`

