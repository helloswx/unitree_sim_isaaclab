# 🚀 快速运行 Demo 指南

## 前置检查

### 1. 激活环境

```bash
conda activate unitree_sim_env
```

### 2. 下载资产文件（如果还未下载）

```bash
cd ~/桌面/playground/unitree_sim_isaaclab
sudo apt update
sudo apt install git-lfs
. fetch_assets.sh
```

## 🎮 运行 Demo

### ⚙️ 运行前设置（重要）

每次运行前需要设置 cyclonedds 环境变量：

```bash
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh  # 设置 cyclonedds 环境变量
```

或者手动设置：

```bash
export CYCLONEDDS_HOME="$HOME/cyclonedds/install"
export CMAKE_PREFIX_PATH="$HOME/cyclonedds/install:$CMAKE_PREFIX_PATH"
export LD_LIBRARY_PATH="$HOME/cyclonedds/install/lib:$LD_LIBRARY_PATH"
```

**持久化环境变量（推荐）：**

将以下内容添加到 `~/.bashrc` 或 `~/.zshrc`：

```bash
# unitree_sim_isaaclab cyclonedds 环境变量
export CYCLONEDDS_HOME="$HOME/cyclonedds/install"
export CMAKE_PREFIX_PATH="$HOME/cyclonedds/install:$CMAKE_PREFIX_PATH"
export LD_LIBRARY_PATH="$HOME/cyclonedds/install/lib:$LD_LIBRARY_PATH"
```

### 最简单的 Demo（推荐首次运行）

**G1 机器人抓取圆柱体任务（二指夹爪）：**

```bash
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh  # 设置环境变量

python sim_main.py \
    --device cpu \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129
```

### 其他可用的 Demo 任务

#### G1 机器人任务

**1. 抓取圆柱体（三指灵巧手）：**
```bash
python sim_main.py \
    --device cpu \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex3-Joint \
    --enable_dex3_dds \
    --robot_type g129
```

**2. 抓取红色木块（二指夹爪）：**
```bash
python sim_main.py \
    --device cpu \
    --enable_cameras \
    --task Isaac-PickPlace-RedBlock-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129
```

**3. 堆叠彩色木块（二指夹爪）：**
```bash
python sim_main.py \
    --device cpu \
    --enable_cameras \
    --task Isaac-Stack-RgyBlock-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129
```

**4. 移动并抓取圆柱体（Wholebody 任务，支持移动）：**
```bash
python sim_main.py \
    --device cpu \
    --enable_cameras \
    --task Isaac-Move-Cylinder-G129-Dex1-Wholebody \
    --enable_dex1_dds \
    --robot_type g129
```

#### H1-2 机器人任务

```bash
python sim_main.py \
    --device cpu \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-H12-27dof-Inspire-Joint \
    --enable_inspire_dds \
    --robot_type h1_2
```

## 📋 参数说明

- `--device cpu`: 使用 CPU（也可以使用 `cuda` 如果有 GPU）
- `--enable_cameras`: 启用相机
- `--task`: 任务名称（见上面的示例）
- `--enable_dex1_dds`: 启用二指夹爪 DDS（用于控制夹爪）
- `--enable_dex3_dds`: 启用三指灵巧手 DDS
- `--enable_inspire_dds`: 启用 Inspire 手 DDS
- `--robot_type g129`: 机器人类型（g129 或 h1_2）
- `--headless`: 无头模式（不显示窗口，用于服务器环境）

## 🎯 查看主视图

启动后，在 Isaac Sim 界面中：
1. 点击左侧场景树中的 **PerspectiveCamera**
2. 展开 **Cameras**
3. 点击 **PerspectiveCamera** 查看主视图

## 🎮 控制机器人（可选）

如果需要控制机器人移动（仅 Wholebody 任务支持），可以使用：

**方法 1: 键盘控制**
```bash
# 在另一个终端运行
python send_commands_keyboard.py
```

**方法 2: 8位控制器**
```bash
# 在另一个终端运行
python send_commands_8bit.py
```

## ⚠️ 常见问题

### 1. 找不到任务

如果提示找不到任务，确保：
- 已激活正确的 conda 环境
- 已安装 Isaac Lab
- 任务名称拼写正确

### 2. 窗口不显示

- 检查是否有显示设备（DISPLAY 环境变量）
- 如果使用 SSH，需要 X11 转发
- 或者使用 `--headless` 参数

### 3. DDS 连接问题

- 确保没有其他程序占用 DDS 端口
- 检查网络配置

### 4. 资产文件缺失

运行 `bash fetch_assets.sh` 下载所需资产

## 🎬 预期效果

运行成功后，你应该能看到：
- Isaac Sim 窗口打开
- G1 机器人出现在场景中
- 机器人执行抓取任务
- 相机视图显示机器人的视角

## 📚 更多信息

- 查看 [README_zh-CN.md](README_zh-CN.md) 了解完整文档
- 查看任务列表了解所有可用任务

