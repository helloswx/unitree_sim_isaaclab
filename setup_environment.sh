#!/bin/bash
# Isaac Sim 5.0.0 环境安装脚本
# 适用于 RTX 50 系列显卡（包括 RTX 5070 Ti）
# Ubuntu 22.04+ 使用 pip 安装方式

set -e  # 遇到错误立即退出

echo "=========================================="
echo "Unitree Sim IsaacLab 环境安装脚本"
echo "适用于 RTX 50 系列显卡"
echo "=========================================="

# 检查是否为 root 用户
if [ "$EUID" -eq 0 ]; then 
   echo "请不要使用 root 用户运行此脚本"
   exit 1
fi

# 0. 检查 NVIDIA 驱动
echo ""
echo "步骤 0: 检查 NVIDIA 驱动..."
if command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA 驱动已安装:"
    nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
else
    echo "⚠️  警告: 未检测到 NVIDIA 驱动！"
    echo ""
    echo "请先安装 NVIDIA 驱动:"
    echo "  Ubuntu 24.04: sudo apt install -y nvidia-driver-550"
    echo "  或使用: sudo ubuntu-drivers autoinstall"
    echo ""
    echo "安装后请重启系统，然后重新运行此脚本。"
    echo ""
    read -p "是否继续安装其他组件? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 1. 检查系统依赖
echo ""
echo "步骤 1: 检查系统依赖..."
sudo apt update
sudo apt install -y \
    git \
    git-lfs \
    cmake \
    build-essential \
    curl \
    wget

# 2. 检查并安装 conda
echo ""
echo "步骤 2: 检查 conda 安装..."
if ! command -v conda &> /dev/null; then
    echo "未检测到 conda，正在安装 Miniconda..."
    CONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
    if [ ! -f "$CONDA_INSTALLER" ]; then
        wget https://repo.anaconda.com/miniconda/$CONDA_INSTALLER
    fi
    bash $CONDA_INSTALLER -b -p $HOME/miniconda3
    eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
    conda init bash
    echo "Conda 安装完成，请重新运行此脚本或手动执行: source ~/.bashrc"
    exit 0
else
    echo "Conda 已安装"
    eval "$(conda shell.bash hook)"
fi

# 2.5. 接受 conda TOS（如果需要）
echo ""
echo "步骤 2.5: 检查并接受 conda Terms of Service..."
if conda tos list 2>/dev/null | grep -q "not accepted"; then
    echo "接受 conda TOS..."
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true
    echo "Conda TOS 已接受"
else
    echo "Conda TOS 已接受或无需接受"
fi

# 3. 创建虚拟环境
echo ""
echo "步骤 3: 创建 conda 虚拟环境..."
ENV_NAME="unitree_sim_env"
if conda env list | grep -q "^${ENV_NAME} "; then
    echo "环境 ${ENV_NAME} 已存在，是否删除并重新创建? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        conda env remove -n ${ENV_NAME} -y
        conda create -n ${ENV_NAME} python=3.11 -y
    else
        echo "使用现有环境"
    fi
else
    conda create -n ${ENV_NAME} python=3.11 -y
fi

# 激活环境
conda activate ${ENV_NAME}

# 4. 安装 PyTorch (CUDA 12.6)
echo ""
echo "步骤 4: 安装 PyTorch (CUDA 12.6)..."
pip install --upgrade pip
pip install torch==2.7.0 torchvision==0.22.0 torchaudio==2.7.0 --index-url https://download.pytorch.org/whl/cu126

# 5. 安装 Isaac Sim 5.0.0
echo ""
echo "步骤 5: 安装 Isaac Sim 5.0.0..."
echo "这可能需要较长时间，请耐心等待..."
pip install --upgrade pip
pip install "isaacsim[all,extscache]==5.0.0" --extra-index-url https://pypi.nvidia.com

echo ""
echo "验证 Isaac Sim 安装..."
isaacsim --help || echo "注意: 首次运行 isaacsim 需要接受 EULA"

# 6. 安装 Isaac Lab
echo ""
echo "步骤 6: 安装 Isaac Lab..."
ISAACLAB_DIR="$HOME/IsaacLab"
if [ ! -d "$ISAACLAB_DIR" ]; then
    echo "克隆 Isaac Lab 仓库..."
    git clone https://github.com/isaac-sim/IsaacLab.git $ISAACLAB_DIR
fi

cd $ISAACLAB_DIR
git checkout v2.2.0

echo "运行 Isaac Lab 安装脚本..."
./isaaclab.sh --install

echo ""
echo "验证 Isaac Lab 安装..."
python scripts/tutorials/00_sim/create_empty.py || echo "如果出现错误，请检查安装日志"

# 7. 安装 unitree_sdk2_python
echo ""
echo "步骤 7: 安装 unitree_sdk2_python..."
UNITREE_SDK_DIR="$HOME/unitree_sdk2_python"
if [ ! -d "$UNITREE_SDK_DIR" ]; then
    echo "克隆 unitree_sdk2_python 仓库..."
    git clone https://github.com/unitreerobotics/unitree_sdk2_python $UNITREE_SDK_DIR
fi

cd $UNITREE_SDK_DIR
pip install -e .

# 8. 安装项目依赖
echo ""
echo "步骤 8: 安装项目依赖..."
cd /home/bz/桌面/playground/unitree_sim_isaaclab
pip install -r requirements.txt

# 9. 下载资产文件
echo ""
echo "步骤 9: 下载资产文件..."
if [ -f "fetch_assets.sh" ]; then
    bash fetch_assets.sh
else
    echo "警告: 未找到 fetch_assets.sh 文件"
fi

# 10. 处理常见问题
echo ""
echo "步骤 10: 处理常见问题..."
# 安装 libstdc++ 更新版本（如果需要）
conda install -c conda-forge libstdcxx-ng -y || echo "libstdc++ 安装跳过"

echo ""
echo "=========================================="
echo "安装完成！"
echo "=========================================="
echo ""
echo "使用说明:"
echo "1. 激活环境: conda activate ${ENV_NAME}"
echo "2. 运行仿真: python sim_main.py --device cpu --enable_cameras --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint --enable_dex1_dds --robot_type g129"
echo ""
echo "如果遇到问题，请参考:"
echo "- doc/isaacsim5.0_install_zh.md"
echo "- https://github.com/unitreerobotics/unitree_sdk2_python (unitree_sdk2_python FAQ)"
echo ""

