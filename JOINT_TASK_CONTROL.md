# 🎯 Joint 任务控制指南

## 重要说明

**`Isaac-PickPlace-RedBlock-G129-Dex1-Joint` 是 Joint 任务（固定位置）**

### ❌ Joint 任务不支持键盘移动控制

**原因：**
- Joint 任务：机器人固定在某个位置，只控制手臂和手部
- Wholebody 任务：机器人可以移动，支持键盘控制

**从你的日志可以看到：**
```
args_cli.task: Isaac-PickPlace-RedBlock-G129-Dex1-Joint
```

**注意：** 日志中**没有** `[run_command_dds]`，因为 Joint 任务不需要移动命令。

---

## 🤖 让 Joint 任务的机器人执行动作的方法

### 方法 1: 使用训练好的策略模型（推荐）

如果你有训练好的 RL 策略模型（`.onnx` 文件）：

```bash
# 停止当前任务
bash kill_sim.sh

# 重新启动，添加 --model_path 参数
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-PickPlace-RedBlock-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --model_path assets/model/policy.onnx \
    --render_interval 10
```

**注意：** 需要先有训练好的策略模型文件。

---

### 方法 2: 使用 Replay 模式（如果有数据）

如果你有预录制的动作数据：

```bash
# 停止当前任务
bash kill_sim.sh

# 使用 replay 模式
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-PickPlace-RedBlock-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --replay_data \
    --file_path /path/to/your/data \
    --render_interval 10
```

**注意：** 需要先有录制的数据文件。

---

### 方法 3: 连接真实机器人或外部控制程序

Joint 任务通过 DDS 接收手臂和手部的控制命令：

- **机器人身体命令**: 通过 `g129` DDS 通道
- **夹爪命令**: 通过 `dex1` DDS 通道

如果你有外部控制程序（如遥操作、策略推理等），可以通过 DDS 发送命令。

---

### 方法 4: 切换到 Wholebody 任务（如果想用键盘控制）

如果你想用键盘控制机器人移动，需要切换到 Wholebody 任务：

```bash
# 停止当前任务
bash kill_sim.sh

# 切换到 Wholebody 任务
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

# 然后在另一个终端运行键盘控制
bash start_keyboard_control.sh
```

---

## 📊 任务类型对比

| 任务类型 | 支持键盘移动 | 机器人位置 | 控制方式 |
|---------|------------|-----------|---------|
| **Joint** | ❌ 不支持 | 固定位置 | 需要策略模型/replay/外部控制 |
| **Wholebody** | ✅ 支持 | 可移动 | 键盘控制/策略模型 |

---

## 🔍 当前状态分析

从你的日志可以看到：

```
args_cli.task: Isaac-PickPlace-RedBlock-G129-Dex1-Joint  ← Joint 任务
[DDSActionProvider] DDS communication initialized        ← DDS 已初始化
[SimpleController] the controller is started             ← 控制器已启动
```

**状态：**
- ✅ 环境已创建
- ✅ 机器人已加载
- ✅ DDS 通信已建立
- ⚠️ **等待控制命令**（手臂/手部命令）

**问题：**
- 没有策略模型，机器人不会自动执行
- 没有外部控制程序，机器人保持静止
- 这是**正常行为**，因为 Joint 任务需要外部命令源

---

## 🎯 推荐方案

### 方案 A: 如果有策略模型

使用 `--model_path` 参数指定模型文件。

### 方案 B: 如果想看机器人移动

切换到 Wholebody 任务 + 键盘控制。

### 方案 C: 如果只是想测试环境

当前状态是正常的，机器人会保持静止等待命令。

---

## ❓ 常见问题

### Q1: 为什么机器人不动？

**答案：** Joint 任务需要外部控制命令（策略模型、replay 数据或外部程序）。如果没有命令源，机器人会保持静止，这是正常的。

### Q2: 可以用键盘控制吗？

**答案：** Joint 任务不支持键盘移动控制。只有 Wholebody 任务支持。

### Q3: 如何让机器人执行抓取动作？

**答案：** 需要：
1. 训练好的策略模型（`.onnx` 文件）
2. 或预录制的 replay 数据
3. 或连接外部控制程序

### Q4: 没有策略模型怎么办？

**答案：**
- 切换到 Wholebody 任务，用键盘控制机器人移动
- 或查看项目文档，了解如何训练策略
- 或使用 replay 模式（如果有数据）

---

## 📝 总结

**当前情况：**
- ✅ 任务已启动：`Isaac-PickPlace-RedBlock-G129-Dex1-Joint`
- ✅ 机器人已加载
- ✅ DDS 通信正常
- ⚠️ 机器人等待控制命令（这是正常的）

**要让机器人执行动作，需要：**
1. 策略模型（`--model_path`）
2. Replay 数据（`--replay_data`）
3. 或切换到 Wholebody 任务使用键盘控制

**如果没有策略模型或数据：**
- 机器人会保持静止（正常行为）
- 可以切换到 Wholebody 任务体验键盘控制

