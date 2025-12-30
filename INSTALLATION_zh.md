# 环境安装完整指南

本指南详细说明如何在 Ubuntu 系统上搭建 Unitree Sim IsaacLab 的完整开发环境。

## 📋 目录

- [系统要求](#系统要求)
- [前置准备](#前置准备)
- [快速安装（推荐）](#快速安装推荐)
- [详细安装步骤](#详细安装步骤)
- [常见问题](#常见问题)
- [验证安装](#验证安装)

## 系统要求

### 硬件要求
- **显卡**: NVIDIA RTX 系列（RTX 30/40/50 系列）
  - RTX 30/40 系列：使用 Isaac Sim 4.5.0 或 5.0.0
  - **RTX 50 系列（包括 RTX 5070 Ti）**：**必须使用 Isaac Sim 5.0.0**
- **内存**: 16GB+（推荐 32GB+）
- **存储**: 至少 50GB 可用空间
- **CPU**: 多核处理器（推荐 8 核以上）

### 软件要求
- **操作系统**: Ubuntu 22.04 或更高版本（推荐 Ubuntu 22.04 或 24.04）
- **NVIDIA 驱动**: 550+ 版本
- **CUDA**: 12.0+（可通过 PyTorch 自动安装）

## 前置准备

### 1. 检查系统环境

运行系统检查脚本：

```bash
cd unitree_sim_isaaclab
bash check_system.sh
```

### 2. 安装 NVIDIA 驱动

#### 2.1 检查当前驱动状态

```bash
nvidia-smi
```

如果显示正常，说明驱动已安装。如果报错，继续下一步。

#### 2.2 安装/更新 NVIDIA 驱动

**Ubuntu 24.04:**

```bash
sudo apt update
sudo apt install -y nvidia-driver-550  # 或更新版本
sudo reboot
```

**或使用自动安装:**

```bash
sudo ubuntu-drivers autoinstall
sudo reboot
```

#### 2.3 验证驱动安装

重启后运行：

```bash
nvidia-smi
```

应该能看到你的显卡信息（例如 RTX 5070 Ti）。

#### 2.4 处理 Secure Boot 问题（如需要）

如果遇到 `Key was rejected by service` 错误：

1. 重启进入 BIOS/UEFI（开机时按 F2/Del/F10 等）
2. 找到 `Security` → `Secure Boot`，设置为 `Disabled`
3. 保存并重启
4. 重新安装驱动：`sudo ubuntu-drivers autoinstall && sudo reboot`

### 3. 配置 Git（用于克隆大型仓库）

```bash
# 增加 Git 缓冲区大小，避免克隆大型仓库时出错
git config --global http.postBuffer 524288000
git config --global http.maxRequestBuffer 100M
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999
```

## 快速安装（推荐）

### 方法一：使用自动安装脚本

1. **接受 Conda TOS（首次使用需要）**

```bash
# 如果 conda 未初始化，先初始化
eval "$($HOME/miniconda3/bin/conda shell.bash hook)"  # 根据你的 conda 路径调整

# 接受 TOS
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
```

2. **运行安装脚本**

```bash
cd unitree_sim_isaaclab
bash setup_environment.sh
```

脚本会自动：
- ✅ 安装系统依赖
- ✅ 安装 Miniconda（如需要）
- ✅ 创建 Python 3.11 虚拟环境
- ✅ 安装 PyTorch (CUDA 12.6)
- ✅ 安装 Isaac Sim 5.0.0
- ✅ 安装 Isaac Lab v2.2.0
- ✅ 安装 unitree_sdk2_python
- ✅ 安装项目依赖

**注意**: 如果 IsaacLab 克隆失败（网络问题），请参考[手动安装步骤](#手动安装-isaac-lab)。

## 详细安装步骤

### 步骤 1: 安装 Miniconda

如果未安装 conda：

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
source ~/.bashrc
```

### 步骤 2: 创建虚拟环境

```bash
conda create -n unitree_sim_env python=3.11 -y
conda activate unitree_sim_env
```

**首次使用需要接受 Conda TOS:**

```bash
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
```

### 步骤 3: 安装 PyTorch

```bash
pip install --upgrade pip
pip install torch==2.7.0 torchvision==0.22.0 torchaudio==2.7.0 --index-url https://download.pytorch.org/whl/cu126
```

### 步骤 4: 安装 Isaac Sim 5.0.0

**重要**: RTX 50 系列显卡必须使用 Isaac Sim 5.0.0！

```bash
pip install --upgrade pip
pip install "isaacsim[all,extscache]==5.0.0" --extra-index-url https://pypi.nvidia.com
```

**验证安装:**

```bash
isaacsim
# 首次运行会提示接受 EULA，输入: Yes
```

### 步骤 5: 安装 Isaac Lab

#### 方法 A: 使用安装脚本（推荐）

```bash
git clone https://github.com/isaac-sim/IsaacLab.git ~/IsaacLab
cd ~/IsaacLab
git checkout v2.2.0
./isaaclab.sh --install
```

#### 方法 B: 手动安装（如果网络不稳定）

如果克隆失败，可以尝试：

```bash
# 使用浅克隆减少数据量
cd ~
git clone --depth 1 https://github.com/isaac-sim/IsaacLab.git
cd ~/IsaacLab
git checkout v2.2.0
./isaaclab.sh --install
```

**验证安装:**

```bash
cd ~/IsaacLab
python scripts/tutorials/00_sim/create_empty.py
```

### 步骤 6: 安装 unitree_sdk2_python

```bash
git clone https://github.com/unitreerobotics/unitree_sdk2_python ~/unitree_sdk2_python
cd ~/unitree_sdk2_python
pip install -e .
```

**如果遇到 cyclonedds 错误:**

参考 [unitree_sdk2_python FAQ](https://github.com/unitreerobotics/unitree_sdk2_python?tab=readme-ov-file#faq)

通常需要：

```bash
sudo apt install -y \
    build-essential \
    cmake \
    libssl-dev \
    libxml2-dev

cd ~/unitree_sdk2_python
pip install -e .
```

### 步骤 7: 安装项目依赖

```bash
cd unitree_sim_isaaclab
pip install -r requirements.txt
```

### 步骤 8: 下载资产文件

```bash
sudo apt update
sudo apt install git-lfs
. fetch_assets.sh
```

## 常见问题

### 1. libstdc++.so.6 版本过低

**错误信息:**
```
OSError: version GLIBCXX_3.4.30' not found
```

**解决方法:**
```bash
conda activate unitree_sim_env
conda install -c conda-forge libstdcxx-ng -y
```

### 2. Conda TOS 未接受

**错误信息:**
```
CondaToSNonInteractiveError: Terms of Service have not been accepted
```

**解决方法:**
```bash
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
```

### 3. IsaacLab 克隆失败

**错误信息:**
```
error: RPC 失败。curl 56 Recv failure: 连接被对方重置
```

**解决方法:**

1. 增加 Git 缓冲区（见[前置准备](#3-配置-git用于克隆大型仓库)）
2. 使用浅克隆：
   ```bash
   git clone --depth 1 https://github.com/isaac-sim/IsaacLab.git
   ```
3. 如果使用代理：
   ```bash
   git config --global http.proxy http://127.0.0.1:7890
   git config --global https.proxy http://127.0.0.1:7890
   ```

### 4. NVIDIA 驱动问题

**错误信息:**
```
NVIDIA-SMI has failed because it couldn't communicate with the NVIDIA driver
```

**解决方法:**

1. 检查驱动安装：
   ```bash
   ubuntu-drivers devices
   sudo ubuntu-drivers autoinstall
   sudo reboot
   ```

2. 如果遇到 Secure Boot 问题，参考[前置准备 2.4](#24-处理-secure-boot-问题如需要)

### 5. unitree_sdk2_python 安装失败

**错误信息:**
```
Could not locate cyclonedds. Try to set CYCLONEDDS_HOME or CMAKE_PREFIX_PATH
```

**解决方法:**

参考 [unitree_sdk2_python FAQ](https://github.com/unitreerobotics/unitree_sdk2_python?tab=readme-ov-file#faq)

安装依赖：
```bash
sudo apt install -y \
    build-essential \
    cmake \
    libssl-dev \
    libxml2-dev
```

### 6. 网络问题（需要代理）

如果下载速度慢或无法访问 NVIDIA PyPI：

```bash
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
# 然后运行安装命令
```

## 验证安装

### 1. 验证 Isaac Sim

```bash
conda activate unitree_sim_env
isaacsim --help
```

### 2. 验证 Isaac Lab

```bash
cd ~/IsaacLab
python scripts/tutorials/00_sim/create_empty.py
```

### 3. 验证项目运行

```bash
cd unitree_sim_isaaclab
conda activate unitree_sim_env

# 测试运行（无头模式）
python sim_main.py \
    --device cpu \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --headless
```

## 下一步

- 查看 [README_zh-CN.md](README_zh-CN.md) 了解项目详情
- 查看 [QUICKSTART_zh.md](QUICKSTART_zh.md) 快速开始
- 参考任务场景搭建指南创建自定义任务

## 获取帮助

- GitHub Issues: https://github.com/unitreerobotics/unitree_sim_isaaclab/issues
- Discord: https://discord.gg/ZwcVwxv5rq

## 安装时间估算

- NVIDIA 驱动安装: 5-10 分钟
- Miniconda 安装: 2-5 分钟
- PyTorch 安装: 5-10 分钟
- Isaac Sim 5.0.0 安装: **30-60 分钟**（取决于网络速度）
- Isaac Lab 安装: 10-20 分钟
- unitree_sdk2_python: 5-10 分钟
- 项目依赖: 2-5 分钟

**总计**: 约 1-2 小时（主要取决于网络速度）

