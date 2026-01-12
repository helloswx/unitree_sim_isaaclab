#!/bin/bash
# 安装 unitree_sdk2_python 脚本

set -o pipefail

echo "=========================================="
echo "安装 unitree_sdk2_python"
echo "=========================================="

# 检查是否在正确的环境
if [ -z "$CONDA_DEFAULT_ENV" ] || [ "$CONDA_DEFAULT_ENV" != "unitree_sim_env" ]; then
    echo "⚠️  警告: 当前不在 unitree_sim_env 环境中"
    echo "请先运行: conda activate unitree_sim_env"
    exit 1
fi

echo ""
echo "步骤 1: 检查系统依赖..."
MISSING_DEPS=()

for dep in build-essential cmake libssl-dev libxml2-dev pkg-config; do
    if ! dpkg -l | grep -q "^ii.*$dep"; then
        MISSING_DEPS+=("$dep")
    fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo "需要安装以下系统依赖:"
    echo "  ${MISSING_DEPS[*]}"
    echo ""
    echo "请运行以下命令安装（需要 sudo 权限）:"
    echo "  sudo apt update"
    echo "  sudo apt install -y ${MISSING_DEPS[*]}"
    echo ""
    read -p "是否现在安装? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt update
        sudo apt install -y "${MISSING_DEPS[@]}"
    else
        echo "请手动安装依赖后重新运行此脚本"
        exit 1
    fi
else
    echo "✓ 系统依赖已安装"
fi

echo ""
echo "步骤 2: 检查 unitree_sdk2_python..."
if [ ! -d "$HOME/unitree_sdk2_python" ]; then
    echo "克隆 unitree_sdk2_python 仓库..."
    cd ~
    git clone https://github.com/unitreerobotics/unitree_sdk2_python.git
else
    echo "✓ unitree_sdk2_python 目录已存在"
fi

echo ""
echo "步骤 3: 安装 unitree_sdk2_python..."
cd ~/unitree_sdk2_python

# 尝试安装
if pip install -e .; then
    echo ""
    echo "✓ 安装成功！"
else
    echo ""
    echo "❌ 安装失败"
    echo ""
    echo "如果遇到 cyclonedds 错误，尝试以下方法:"
    echo ""
    echo "方法 1: 设置环境变量"
    echo "  export CYCLONEDDS_HOME=/usr"
    echo "  export CMAKE_PREFIX_PATH=/usr:\$CMAKE_PREFIX_PATH"
    echo "  pip install -e ."
    echo ""
    echo "方法 2: 安装 cyclonedds C 库（如果可用）"
    echo "  sudo apt install -y libcyclonedds-dev"
    echo "  pip install -e ."
    echo ""
    echo "方法 3: 查看官方 FAQ"
    echo "  https://github.com/unitreerobotics/unitree_sdk2_python#faq"
    exit 1
fi

echo ""
echo "步骤 4: 验证安装..."
if python -c "import unitree_sdk2py; print('✓ unitree_sdk2py 安装成功')" 2>/dev/null; then
    echo ""
    echo "=========================================="
    echo "✅ 完成！unitree_sdk2_python 已安装"
    echo "=========================================="
else
    echo "⚠️  验证失败，但可能仍然可以使用"
fi

