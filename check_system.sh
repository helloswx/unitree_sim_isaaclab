#!/bin/bash
# 系统环境检查脚本

echo "=========================================="
echo "系统环境检查"
echo "=========================================="

# 检查 Ubuntu 版本
echo ""
echo "1. 检查 Ubuntu 版本:"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "   发行版: $PRETTY_NAME"
    echo "   版本: $VERSION_ID"
    if [[ "$VERSION_ID" == "22.04" ]] || [[ "$VERSION_ID" == "24.04" ]] || [[ "$VERSION_ID" > "22.04" ]]; then
        echo "   ✓ Ubuntu 版本符合要求 (22.04+)"
    else
        echo "   ⚠ Ubuntu 版本可能不兼容，建议使用 22.04 或更高版本"
    fi
else
    echo "   ⚠ 无法检测 Ubuntu 版本"
fi

# 检查 NVIDIA 驱动
echo ""
echo "2. 检查 NVIDIA 驱动:"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
    echo "   ✓ NVIDIA 驱动已安装"
else
    echo "   ⚠ 未检测到 NVIDIA 驱动"
    echo "   请安装 NVIDIA 驱动: sudo apt install nvidia-driver-xxx"
fi

# 检查 CUDA
echo ""
echo "3. 检查 CUDA:"
if command -v nvcc &> /dev/null; then
    nvcc --version | grep "release"
    echo "   ✓ CUDA 已安装"
else
    echo "   ℹ CUDA 将通过 PyTorch 安装（Isaac Sim 5.0.0 会自动处理）"
fi

# 检查 conda
echo ""
echo "4. 检查 conda:"
if command -v conda &> /dev/null; then
    conda --version
    echo "   ✓ Conda 已安装"
else
    echo "   ⚠ Conda 未安装，安装脚本将自动安装 Miniconda"
fi

# 检查 Python
echo ""
echo "5. 检查 Python:"
if command -v python3 &> /dev/null; then
    python3 --version
    echo "   ✓ Python 已安装"
else
    echo "   ⚠ Python 未安装"
fi

# 检查 Git
echo ""
echo "6. 检查 Git:"
if command -v git &> /dev/null; then
    git --version
    echo "   ✓ Git 已安装"
else
    echo "   ⚠ Git 未安装，安装脚本将自动安装"
fi

# 检查磁盘空间
echo ""
echo "7. 检查磁盘空间:"
AVAILABLE_SPACE=$(df -h $HOME | tail -1 | awk '{print $4}')
echo "   可用空间: $AVAILABLE_SPACE"
echo "   建议至少 50GB 可用空间"

# 检查网络连接
echo ""
echo "8. 检查网络连接:"
if ping -c 1 -W 2 github.com &> /dev/null; then
    echo "   ✓ 可以访问 GitHub"
else
    echo "   ⚠ 无法访问 GitHub，可能需要配置代理"
fi

if ping -c 1 -W 2 pypi.nvidia.com &> /dev/null; then
    echo "   ✓ 可以访问 NVIDIA PyPI"
else
    echo "   ⚠ 无法访问 NVIDIA PyPI，可能需要配置代理"
fi

echo ""
echo "=========================================="
echo "检查完成"
echo "=========================================="

