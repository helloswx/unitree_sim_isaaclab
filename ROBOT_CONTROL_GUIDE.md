# 🤖 机器人控制指南

## 当前状态

你已经成功启动了 Isaac Sim，机器人已经加载在场景中。现在需要让机器人执行动作。

## 🎯 让机器人动起来的三种方式

### 方式 1: 键盘控制（最简单，推荐）

**适用于：** Wholebody 任务（机器人可以移动）或需要手动控制的情况

**步骤：**

1. **保持当前 sim_main.py 运行**（不要关闭）

2. **打开新终端**，运行键盘控制脚本：

```bash
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

python send_commands_keyboard.py
```

3. **控制说明：**
   - `W`: 前进
   - `S`: 后退
   - `A`: 左移
   - `D`: 右移
   - `Z`: 左转
   - `X`: 右转
   - `C`: 下蹲
   - `Q`: 退出程序

**注意：** 键盘控制主要用于 Wholebody 任务（机器人移动）。对于 Joint 任务（固定位置），机器人会等待手臂/手部命令。

---

### 方式 2: 使用预录制的动作数据（推荐用于演示）

**适用于：** 想要看到机器人执行完整任务动作

**步骤：**

1. **停止当前运行的 sim_main.py**（按 Ctrl+C）

2. **使用 replay 模式运行：**

```bash
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --replay_data \
    --render_interval 10
```

**注意：** 需要先有录制的数据文件。如果没有，机器人可能不会动。

---

### 方式 3: 使用训练好的策略模型（如果有）

**适用于：** 已经训练好 RL 策略的情况

```bash
python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --model_path assets/model/policy.onnx \
    --render_interval 10
```

---

## 🎮 针对不同任务的控制方式

### Joint 任务（固定位置，只动手臂）

**任务示例：**
- `Isaac-PickPlace-Cylinder-G129-Dex1-Joint`
- `Isaac-PickPlace-RedBlock-G129-Dex1-Joint`
- `Isaac-Stack-RgyBlock-G129-Dex1-Joint`

**控制方式：**
- 这些任务需要**手臂和手部的控制命令**
- 当前使用 `--enable_dex1_dds` 会等待 DDS 命令
- **如果没有外部命令源，机器人会保持静止**

**解决方案：**
1. 使用 replay 模式（如果有数据）
2. 使用训练好的策略模型
3. 连接真实机器人或 DDS 控制程序

### Wholebody 任务（机器人可以移动）

**任务示例：**
- `Isaac-Move-Cylinder-G129-Dex1-Wholebody`

**控制方式：**
- 可以使用键盘控制机器人移动
- 在另一个终端运行 `python send_commands_keyboard.py`

---

## 🚀 快速演示（推荐）

### 方案 A: 使用键盘控制 Wholebody 任务

**终端 1 - 启动仿真：**
```bash
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-Move-Cylinder-G129-Dex1-Wholebody \
    --enable_dex1_dds \
    --robot_type g129 \
    --render_interval 10
```

**终端 2 - 键盘控制：**
```bash
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

python send_commands_keyboard.py
```

然后按 `W/A/S/D/Z/X/C` 控制机器人移动。

### 方案 B: 查看自动执行的任务（如果有策略）

如果你有训练好的策略模型，机器人会自动执行任务：

```bash
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --model_path assets/model/policy.onnx \
    --render_interval 10
```

---

## ❓ 常见问题

### Q1: 为什么机器人不动？

**可能原因：**
1. **Joint 任务**：需要手臂控制命令，当前只有 DDS 等待，没有命令源
2. **没有策略模型**：需要训练好的策略或 replay 数据
3. **DDS 未连接**：检查是否有其他程序在发送 DDS 命令

**解决方案：**
- 切换到 Wholebody 任务 + 键盘控制
- 使用 replay 模式（如果有数据）
- 使用训练好的策略模型

### Q2: 如何让机器人自动执行抓取任务？

**需要：**
1. 训练好的 RL 策略模型（`.onnx` 文件）
2. 或预录制的动作数据

**如果没有：**
- 可以尝试 Wholebody 任务 + 键盘控制，手动控制机器人移动
- 或者查看项目文档，了解如何训练策略

### Q3: 键盘控制不工作？

**检查：**
1. 确保在正确的终端运行 `send_commands_keyboard.py`
2. 确保 sim_main.py 正在运行
3. 确保任务类型是 Wholebody（Joint 任务不支持键盘控制移动）

---

## 📝 总结

**当前你的情况：**
- ✅ 仿真已启动
- ✅ 机器人已加载
- ⚠️ 机器人等待命令（因为使用 `--enable_dex1_dds`）

**立即行动：**

1. **如果想看机器人移动：**
   - 切换到 Wholebody 任务
   - 运行键盘控制脚本

2. **如果想看机器人执行任务：**
   - 需要训练好的策略模型
   - 或使用 replay 模式（如果有数据）

3. **如果只是想测试：**
   - 保持当前状态，机器人会保持静止
   - 这是正常的，因为它在等待控制命令

---

## 🎬 下一步

1. 查看 `RUN_DEMO.md` 了解所有可用任务
2. 查看项目文档了解如何训练策略
3. 尝试不同的任务类型和参数

