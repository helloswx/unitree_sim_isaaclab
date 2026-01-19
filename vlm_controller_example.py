#!/usr/bin/env python3
"""
VLM 控制器示例
通过视觉语言模型控制机器人

使用方法:
1. 启动仿真: python sim_main.py --task ...
2. 运行此脚本: python vlm_controller_example.py
"""

import time
import numpy as np
from typing import Optional, Dict, Any
import base64
import io
from PIL import Image
import requests

# DDS 相关
from unitree_sdk2py.core.channel import ChannelPublisher, ChannelFactoryInitialize
from unitree_sdk2py.idl.unitree_hg.msg.dds_ import LowCmd_
from unitree_sdk2py.idl.default import unitree_hg_msg_dds__LowCmd_
from unitree_sdk2py.utils.crc import CRC

# 图像获取
try:
    import zmq
    ZMQ_AVAILABLE = True
except ImportError:
    ZMQ_AVAILABLE = False
    print("警告: zmq 未安装，无法从图像服务器获取图像")


class VLMController:
    """VLM 控制器
    
    功能:
    1. 从仿真环境获取相机图像
    2. 调用 VLM API 获取控制命令
    3. 通过 DDS 发送控制命令到仿真
    """
    
    def __init__(self, vlm_api_url: str = "http://localhost:8000/vlm/infer"):
        """
        Args:
            vlm_api_url: VLM API 地址
        """
        # 初始化 DDS
        print("初始化 DDS 通信...")
        ChannelFactoryInitialize(1)
        self.publisher = ChannelPublisher("rt/lowcmd", LowCmd_)
        self.publisher.Init()
        self.crc = CRC()
        print("DDS 通信初始化完成")
        
        # VLM 配置
        self.vlm_api_url = vlm_api_url
        
        # 图像获取方式
        self.image_source = None
        if ZMQ_AVAILABLE:
            self._setup_image_subscriber()
        
        # 控制参数
        self.default_kp = 100.0  # 位置增益
        self.default_kd = 2.0    # 速度增益
        
        # G1 关节映射（手臂部分）
        self.arm_joint_indices = {
            "left_arm": list(range(15, 22)),   # 左臂 7 个关节
            "right_arm": list(range(22, 29)),   # 右臂 7 个关节
        }
        
    def _setup_image_subscriber(self):
        """设置图像订阅（从图像服务器）"""
        try:
            self.image_context = zmq.Context()
            self.image_socket = self.image_context.socket(zmq.SUB)
            self.image_socket.connect("tcp://localhost:5555")
            self.image_socket.setsockopt_string(zmq.SUBSCRIBE, "")
            self.image_socket.setsockopt(zmq.RCVTIMEO, 1000)  # 1秒超时
            self.image_source = "zmq"
            print("图像订阅器已设置（ZMQ）")
        except Exception as e:
            print(f"设置图像订阅器失败: {e}")
            self.image_source = None
    
    def get_camera_image(self) -> Optional[np.ndarray]:
        """获取相机图像
        
        Returns:
            numpy.ndarray: 图像数组 (H, W, 3)，如果失败返回 None
        """
        if self.image_source == "zmq":
            try:
                # 从 ZMQ 接收图像
                image_data = self.image_socket.recv(flags=zmq.NOBLOCK)
                # 解析图像数据（根据实际格式调整）
                # 这里需要根据图像服务器的实际格式解析
                # image = np.frombuffer(image_data, dtype=np.uint8)
                # image = image.reshape((480, 640, 3))
                # return image
                pass
            except zmq.Again:
                return None
            except Exception as e:
                print(f"获取图像失败: {e}")
                return None
        
        # 其他方式：从共享内存、文件等获取
        return None
    
    def encode_image(self, image: np.ndarray) -> str:
        """将图像编码为 base64
        
        Args:
            image: 图像数组 (H, W, 3)
            
        Returns:
            str: base64 编码的字符串
        """
        if isinstance(image, np.ndarray):
            # 确保是 uint8 类型
            if image.dtype != np.uint8:
                image = (image * 255).astype(np.uint8)
            image = Image.fromarray(image)
        
        buffer = io.BytesIO()
        image.save(buffer, format='JPEG', quality=85)
        return base64.b64encode(buffer.getvalue()).decode('utf-8')
    
    def query_vlm(self, image: np.ndarray, task_description: str = "抓取红色木块") -> Optional[Dict[str, Any]]:
        """查询 VLM 获取控制命令
        
        Args:
            image: 相机图像
            task_description: 任务描述
            
        Returns:
            Dict: VLM 返回的控制命令，格式:
            {
                "left_arm": [7个关节角度],
                "right_arm": [7个关节角度],
                "gripper": 0.5
            }
        """
        # 编码图像
        image_base64 = self.encode_image(image)
        
        # 构建提示词
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
        
        try:
            # 调用 VLM API
            response = requests.post(
                self.vlm_api_url,
                json={
                    "image": image_base64,
                    "prompt": prompt,
                    "max_tokens": 500
                },
                timeout=5.0
            )
            
            if response.status_code == 200:
                result = response.json()
                # 解析响应（根据实际 VLM API 格式调整）
                return self._parse_vlm_response(result)
            else:
                print(f"VLM API 错误: {response.status_code}")
                return None
                
        except requests.exceptions.RequestException as e:
            print(f"VLM API 请求失败: {e}")
            return None
        except Exception as e:
            print(f"解析 VLM 响应失败: {e}")
            return None
    
    def _parse_vlm_response(self, response: Dict) -> Dict[str, Any]:
        """解析 VLM 响应
        
        Args:
            response: VLM API 返回的响应
            
        Returns:
            Dict: 解析后的控制命令
        """
        # 根据实际 VLM API 格式解析
        # 示例：假设 VLM 返回 JSON 字符串
        import json
        
        if "action" in response:
            action_str = response["action"]
            if isinstance(action_str, str):
                action = json.loads(action_str)
            else:
                action = action_str
        else:
            # 尝试直接解析
            action = response
        
        # 验证格式
        if "left_arm" not in action or "right_arm" not in action:
            raise ValueError("VLM 响应格式错误")
        
        return {
            "left_arm": action["left_arm"][:7],
            "right_arm": action["right_arm"][:7],
            "gripper": action.get("gripper", 0.5)
        }
    
    def send_robot_command(self, vlm_response: Dict[str, Any]):
        """通过 DDS 发送机器人控制命令
        
        Args:
            vlm_response: VLM 返回的控制命令
        """
        try:
            cmd = unitree_hg_msg_dds__LowCmd_()
            
            # 初始化所有关节（保持默认值）
            num_motors = len(cmd.motor_cmd)
            for i in range(num_motors):
                cmd.motor_cmd[i].mode = 0x01  # 位置控制模式
                cmd.motor_cmd[i].q = 0.0
                cmd.motor_cmd[i].dq = 0.0
                cmd.motor_cmd[i].tau = 0.0
                cmd.motor_cmd[i].kp = self.default_kp
                cmd.motor_cmd[i].kd = self.default_kd
            
            # 设置左臂关节（15-21）
            left_arm = vlm_response.get("left_arm", [0.0] * 7)
            for i, angle in enumerate(left_arm[:7]):
                joint_idx = 15 + i
                if joint_idx < num_motors:
                    cmd.motor_cmd[joint_idx].q = float(angle)
                    cmd.motor_cmd[joint_idx].kp = self.default_kp
                    cmd.motor_cmd[joint_idx].kd = self.default_kd
            
            # 设置右臂关节（22-28）
            right_arm = vlm_response.get("right_arm", [0.0] * 7)
            for i, angle in enumerate(right_arm[:7]):
                joint_idx = 22 + i
                if joint_idx < num_motors:
                    cmd.motor_cmd[joint_idx].q = float(angle)
                    cmd.motor_cmd[joint_idx].kp = self.default_kp
                    cmd.motor_cmd[joint_idx].kd = self.default_kd
            
            # 设置夹爪（如果需要）
            # gripper_value = vlm_response.get("gripper", 0.5)
            # 夹爪通过单独的 DDS 通道控制
            
            # 计算 CRC
            cmd.crc = self.crc.Crc(cmd)
            
            # 发布命令
            if self.publisher.Write(cmd):
                print(f"✓ 命令已发送: 左臂={left_arm[:3]}, 右臂={right_arm[:3]}")
            else:
                print("⚠️ 命令发送失败（等待订阅者）")
                
        except Exception as e:
            print(f"发送命令失败: {e}")
            import traceback
            traceback.print_exc()
    
    def run(self, task_description: str = "抓取红色木块", frequency: float = 10.0):
        """运行 VLM 控制器主循环
        
        Args:
            task_description: 任务描述
            frequency: 控制频率（Hz）
        """
        print("=" * 60)
        print("VLM 控制器启动")
        print("=" * 60)
        print(f"任务: {task_description}")
        print(f"控制频率: {frequency} Hz")
        print(f"VLM API: {self.vlm_api_url}")
        print("=" * 60)
        print("")
        print("提示: 确保仿真已启动，并且 VLM API 服务正在运行")
        print("按 Ctrl+C 退出")
        print("")
        
        dt = 1.0 / frequency
        iteration = 0
        
        try:
            while True:
                iteration += 1
                start_time = time.time()
                
                # 1. 获取图像
                image = self.get_camera_image()
                if image is None:
                    print(f"[{iteration}] 无法获取图像，跳过...")
                    time.sleep(dt)
                    continue
                
                # 2. 查询 VLM
                print(f"[{iteration}] 查询 VLM...")
                vlm_response = self.query_vlm(image, task_description)
                
                if vlm_response is None:
                    print(f"[{iteration}] VLM 查询失败，跳过...")
                    time.sleep(dt)
                    continue
                
                # 3. 发送命令
                self.send_robot_command(vlm_response)
                
                # 4. 控制频率
                elapsed = time.time() - start_time
                sleep_time = max(0, dt - elapsed)
                if sleep_time > 0:
                    time.sleep(sleep_time)
                else:
                    print(f"⚠️ 控制循环超时: {elapsed:.3f}s > {dt:.3f}s")
                    
        except KeyboardInterrupt:
            print("\n")
            print("=" * 60)
            print("VLM 控制器已停止")
            print("=" * 60)
        except Exception as e:
            print(f"\n错误: {e}")
            import traceback
            traceback.print_exc()


def main():
    """主函数"""
    import argparse
    
    parser = argparse.ArgumentParser(description="VLM 控制器")
    parser.add_argument("--vlm_api_url", type=str, 
                       default="http://localhost:8000/vlm/infer",
                       help="VLM API 地址")
    parser.add_argument("--task", type=str,
                       default="抓取红色木块",
                       help="任务描述")
    parser.add_argument("--frequency", type=float,
                       default=10.0,
                       help="控制频率 (Hz)")
    
    args = parser.parse_args()
    
    # 创建控制器
    controller = VLMController(vlm_api_url=args.vlm_api_url)
    
    # 运行
    controller.run(
        task_description=args.task,
        frequency=args.frequency
    )


if __name__ == "__main__":
    main()

