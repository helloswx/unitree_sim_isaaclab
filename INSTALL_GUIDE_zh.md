# RTX 5070 Ti 环境安装指南

本指南专门针对 **RTX 5070 Ti** (RTX 50 系列) 显卡的环境搭建。

## 重要提示

- **RTX 50 系列显卡必须使用 Isaac Sim 5.0.0 版本**
- 本项目已在 RTX 3080、RTX 3090、RTX 4090 上测试
- RTX 5070 Ti 使用 Isaac Sim 5.0.0 应该可以正常工作

## 前置要求

### 1. 系统要求
- Ubuntu 22.04 或更高版本（推荐 Ubuntu 22.04 或 24.04）
- 至少 50GB 可用磁盘空间
- 16GB+ RAM（推荐 32GB+）

### 2. NVIDIA 驱动安装

首先确保已安装 NVIDIA 驱动：

```bash
# 检查当前驱动
nvidia-smi

# 如果未安装，使用以下命令安装（Ubuntu 24.04）
sudo apt update
sudo apt install -y nvidia-driver-550  # 或更新版本

# 安装后重启系统
sudo reboot
```

### 3. 验证 GPU

```bash
nvidia-smi
```

应该能看到 RTX 5070 Ti 的信息。

## 安装步骤

### 方法一：使用自动安装脚本（推荐）

1. **运行系统检查**
   ```bash
   cd /home/bz/桌面/playground/unitree_sim_isaaclab
   bash check_system.sh
   ```

2. **运行安装脚本**
   ```bash
   bash setup_environment.sh
   ```

   脚本会自动：
   - 安装系统依赖
   - 安装 Miniconda（如果未安装）
   - 创建 Python 3.11 虚拟环境
   - 安装 PyTorch (CUDA 12.6)
   - 安装 Isaac Sim 5.0.0
   - 安装 Isaac Lab v2.2.0
   - 安装 unitree_sdk2_python
   - 安装项目依赖

3. **首次运行 Isaac Sim**
   
   首次运行时会提示接受 EULA：
   ```bash
   conda activate unitree_sim_env
   isaacsim
   # 输入: Yes
   ```

### 方法二：手动安装

如果自动脚本遇到问题，可以按照以下步骤手动安装：

#### 步骤 1: 安装 Miniconda

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
source ~/.bashrc
```

#### 步骤 2: 创建虚拟环境

```bash
conda create -n unitree_sim_env python=3.11 -y
conda activate unitree_sim_env
```

#### 步骤 3: 安装 PyTorch

```bash
pip install --upgrade pip
pip install torch==2.7.0 torchvision==0.22.0 torchaudio==2.7.0 --index-url https://download.pytorch.org/whl/cu126
```

#### 步骤 4: 安装 Isaac Sim 5.0.0

```bash
pip install "isaacsim[all,extscache]==5.0.0" --extra-index-url https://pypi.nvidia.com
```

验证安装：
```bash
isaacsim
# 首次运行输入: Yes
```

#### 步骤 5: 安装 Isaac Lab

```bash
git clone https://github.com/isaac-sim/IsaacLab.git ~/IsaacLab
cd ~/IsaacLab
git checkout v2.2.0
./isaaclab.sh --install
```

验证安装：
```bash
python scripts/tutorials/00_sim/create_empty.py
```

#### 步骤 6: 安装 unitree_sdk2_python

```bash
git clone https://github.com/unitreerobotics/unitree_sdk2_python ~/unitree_sdk2_python
cd ~/unitree_sdk2_python
pip install -e .
```

**注意**: 如果遇到 `cyclonedds` 相关错误，请参考 [unitree_sdk2_python FAQ](https://github.com/unitreerobotics/unitree_sdk2_python?tab=readme-ov-file#faq)

#### 步骤 7: 安装项目依赖

```bash
cd /home/bz/桌面/playground/unitree_sim_isaaclab
pip install -r requirements.txt
```

#### 步骤 8: 下载资产文件

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

### 2. unitree_sdk2_python 安装失败

**错误信息:**
```
Could not locate cyclonedds. Try to set CYCLONEDDS_HOME or CMAKE_PREFIX_PATH
```

**解决方法:**

参考 [unitree_sdk2_python FAQ](https://github.com/unitreerobotics/unitree_sdk2_python?tab=readme-ov-file#faq)

通常需要：
```bash
# 安装 cyclonedds 依赖
sudo apt install -y \
    build-essential \
    cmake \
    libssl-dev \
    libxml2-dev

# 然后重新安装
cd ~/unitree_sdk2_python
pip install -e .
```

### 3. NVIDIA 驱动问题

如果 `nvidia-smi` 无法运行：

```bash
# 检查驱动状态
ubuntu-drivers devices

# 安装推荐驱动
sudo ubuntu-drivers autoinstall

# 或手动安装特定版本
sudo apt install nvidia-driver-550

# 重启
sudo reboot
```

### 4. 网络问题（需要代理）

如果下载速度慢或无法访问 NVIDIA PyPI：

```bash
# 设置代理（根据实际情况修改）
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890

# 然后运行安装命令
```

### 5. 磁盘空间不足

确保至少有 50GB 可用空间：
```bash
df -h
```

## 验证安装

安装完成后，运行以下命令验证：

```bash
# 激活环境
conda activate unitree_sim_env

# 测试 Isaac Sim
isaacsim --help

# 测试 Isaac Lab
cd ~/IsaacLab
python scripts/tutorials/00_sim/create_empty.py

# 测试项目运行
cd /home/bz/桌面/playground/unitree_sim_isaaclab
python sim_main.py --device cpu --enable_cameras --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint --enable_dex1_dds --robot_type g129 --headless
```

## 运行仿真

### 遥操作模式

```bash
conda activate unitree_sim_env
cd /home/bz/桌面/playground/unitree_sim_isaaclab

python sim_main.py \
    --device cpu \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129
```

### 无头模式（Docker 或远程服务器）

添加 `--headless` 参数：
```bash
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
- 查看 [doc/isaacsim5.0_install_zh.md](doc/isaacsim5.0_install_zh.md) 获取更多安装细节
- 参考任务场景搭建指南创建自定义任务

## 获取帮助

- GitHub Issues: https://github.com/unitreerobotics/unitree_sim_isaaclab/issues
- Discord: https://discord.gg/ZwcVwxv5rq

