# 🔧 机器人控制问题排查指南

## 问题：无法控制机器人移动

### ✅ 检查清单

#### 1. 确认任务类型

**Wholebody 任务才支持键盘控制移动！**

检查你运行的任务名称：
- ✅ **支持键盘控制**: `Isaac-Move-Cylinder-G129-Dex1-Wholebody`
- ❌ **不支持键盘控制**: `Isaac-PickPlace-Cylinder-G129-Dex1-Joint`（固定位置任务）

**如果运行的是 Joint 任务：**
- 这些任务只控制手臂，不支持键盘移动
- 需要切换到 Wholebody 任务

#### 2. 确认键盘控制程序已启动

**检查是否有键盘控制进程：**
```bash
pgrep -f "send_commands_keyboard.py"
```

**如果没有运行，启动它：**
```bash
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

# 方法1: 使用脚本（推荐）
bash start_keyboard_control.sh

# 方法2: 直接运行
python send_commands_keyboard.py
```

#### 3. 确认 DDS 通信正常

**检查终端输出，应该看到：**
```
[run_command_dds] Run command DDS node initialized
[run_command_dds] Run command subscriber initialized
```

**如果没有看到这些，可能是 DDS 初始化问题。**

#### 4. 确认环境变量已设置

**必须设置 cyclonedds 环境变量：**
```bash
source setup_env_vars.sh
```

**或者手动设置：**
```bash
export CYCLONEDDS_HOME="$HOME/cyclonedds/install"
export CMAKE_PREFIX_PATH="$HOME/cyclonedds/install:$CMAKE_PREFIX_PATH"
export LD_LIBRARY_PATH="$HOME/cyclonedds/install/lib:$LD_LIBRARY_PATH"
```

#### 5. 确认窗口焦点

- **键盘控制程序需要在终端窗口有焦点**
- 按键盘时，确保终端窗口是活动的（点击终端窗口）
- 不是 Isaac Sim 窗口！

---

## 🚀 完整操作流程

### 步骤 1: 启动仿真（终端 1）

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

**等待看到：**
```
[run_command_dds] Run command DDS node initialized
[run_command_dds] Run command subscriber initialized
```

### 步骤 2: 启动键盘控制（终端 2）

```bash
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

# 使用脚本（推荐）
bash start_keyboard_control.sh

# 或直接运行
python send_commands_keyboard.py
```

**应该看到：**
```
keyboard listener started...
press W/A/S/D/Z/X/C keys to control
press Q key to exit program
```

### 步骤 3: 控制机器人

1. **点击终端 2 窗口**（确保键盘输入被接收）
2. **按键盘控制：**
   - `W` - 前进
   - `S` - 后退
   - `A` - 左移
   - `D` - 右移
   - `Z` - 左转
   - `X` - 右转
   - `C` - 下蹲

3. **观察终端 2 输出：**
   - 应该看到 `commands: [x_vel, y_vel, yaw_vel, height]`
   - 例如：`commands: [0.05, 0.0, 0.0, 0.8]`

---

## ❓ 常见问题

### Q1: 按键盘没有反应

**可能原因：**
1. 键盘控制程序未启动
2. 终端窗口没有焦点
3. 任务类型不是 Wholebody

**解决：**
1. 检查是否有 `send_commands_keyboard.py` 进程
2. 点击终端窗口确保有焦点
3. 确认任务名称包含 "Wholebody"

### Q2: 看到命令输出但机器人不动

**可能原因：**
1. DDS 通信问题
2. 机器人处于错误状态
3. 需要重置环境

**解决：**
1. 检查终端 1 是否有 DDS 错误
2. 尝试重置：在终端 1 按 `Ctrl+C` 停止，然后重新启动
3. 检查机器人是否站立（可能需要先按 `C` 调整高度）

### Q3: 提示 "pynput library missing"

**解决：**
```bash
pip install pynput
```

### Q4: 提示 DDS 初始化失败

**解决：**
1. 确保环境变量已设置：
   ```bash
   source setup_env_vars.sh
   ```

2. 检查 cyclonedds 是否安装：
   ```bash
   ls -la ~/cyclonedds/install/lib/
   ```

3. 如果未安装，参考 `INSTALL_UNITREE_SDK.md` 安装

### Q5: 两个程序都在运行但机器人不动

**检查：**
1. 终端 1 是否显示 `[run_command_dds] Run command subscriber initialized`
2. 终端 2 是否显示 `commands: [...]` 输出
3. 尝试按 `W` 键，观察终端 2 是否有输出

**如果终端 2 有输出但机器人不动：**
- 可能是 DDS 通道问题
- 检查两个程序是否使用相同的 DDS 通道（应该是 channel 1）

---

## 🔍 调试步骤

### 1. 检查进程状态

```bash
# 检查仿真进程
pgrep -f "sim_main.py"

# 检查键盘控制进程
pgrep -f "send_commands_keyboard.py"
```

### 2. 检查 DDS 通信

在终端 1 中应该看到：
```
[run_command_dds] Input shared memory: psm_xxxxx
[run_command_dds] Output shared memory: psm_xxxxx
[run_command_dds] Run command DDS node initialized
```

在终端 2 中应该看到：
```
initializing DDS communication...
DDS communication initialized
```

### 3. 测试键盘输入

1. 点击终端 2 窗口
2. 按 `W` 键
3. 应该看到输出：`[KEY] W: press`
4. 应该看到：`commands: [0.05, 0.0, 0.0, 0.8]`

### 4. 检查机器人状态

在 Isaac Sim 中：
- 机器人应该站立在地面上
- 如果机器人躺倒或位置不对，可能需要重置

---

## 📝 完整示例

**终端 1（仿真）：**
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

**终端 2（键盘控制）：**
```bash
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

bash start_keyboard_control.sh
```

**然后：**
1. 点击终端 2 窗口
2. 按 `W` 键
3. 观察机器人是否前进

---

## ⚠️ 重要提示

1. **键盘控制程序必须在单独的终端运行**
2. **按键盘时，终端窗口必须有焦点**（不是 Isaac Sim 窗口）
3. **只有 Wholebody 任务支持键盘移动控制**
4. **两个程序都需要设置环境变量**

---

## 🎯 快速测试

运行这个命令测试键盘控制是否工作：

```bash
# 在终端 2 中
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

python send_commands_keyboard.py
```

然后：
1. 点击终端窗口
2. 按 `W` 键
3. 应该看到命令输出
4. 如果看到输出但机器人不动，检查 DDS 通信

