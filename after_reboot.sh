#!/bin/bash
# 重启后运行的脚本

echo "=========================================="
echo "NVIDIA 驱动验证和后续安装"
echo "=========================================="

# 1. 验证 NVIDIA 驱动
echo ""
echo "步骤 1: 验证 NVIDIA 驱动..."
if nvidia-smi &> /dev/null; then
    echo "✓ NVIDIA 驱动正常工作:"
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
else
    echo "⚠️  NVIDIA 驱动未正常工作，请检查:"
    echo "  1. 是否已重启系统"
    echo "  2. 运行: sudo dmesg | grep -i nvidia"
    echo "  3. 检查: lsmod | grep nvidia"
    exit 1
fi

# 2. 运行系统检查
echo ""
echo "步骤 2: 运行系统环境检查..."
# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
bash check_system.sh

# 3. 询问是否继续安装
echo ""
echo "步骤 3: 准备运行安装脚本..."
read -p "是否现在运行自动安装脚本? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "开始安装..."
    bash setup_environment.sh
else
    echo "稍后可以运行: bash setup_environment.sh"
fi

