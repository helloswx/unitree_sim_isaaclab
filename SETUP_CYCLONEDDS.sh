#!/bin/bash
# 自动安装 cyclonedds 和 unitree_sdk2_python 脚本

set -o pipefail

echo "=========================================="
echo "自动安装 cyclonedds 和 unitree_sdk2_python"
echo "=========================================="

# 检查环境
if [ -z "$CONDA_DEFAULT_ENV" ] || [ "$CONDA_DEFAULT_ENV" != "unitree_sim_env" ]; then
    echo "⚠️  请先激活环境: conda activate unitree_sim_env"
    exit 1
fi

CYCLONEDDS_DIR="$HOME/cyclonedds"
CYCLONEDDS_INSTALL="$HOME/cyclonedds/install"

echo ""
echo "步骤 1: 编译安装 cyclonedds 0.10.x..."
cd ~

if [ ! -d "$CYCLONEDDS_DIR" ]; then
    echo "克隆 cyclonedds 仓库..."
    git clone https://github.com/eclipse-cyclonedds/cyclonedds -b releases/0.10.x
else
    echo "✓ cyclonedds 目录已存在"
fi

cd "$CYCLONEDDS_DIR"

if [ ! -d "build" ]; then
    echo "创建 build 和 install 目录..."
    mkdir -p build install
fi

cd build

if [ ! -f "Makefile" ]; then
    echo "配置 cmake..."
    cmake .. -DCMAKE_INSTALL_PREFIX=../install
fi

echo "编译并安装 cyclonedds（这可能需要几分钟）..."
cmake --build . --target install

if [ ! -d "$CYCLONEDDS_INSTALL" ]; then
    echo "❌ cyclonedds 安装失败"
    exit 1
fi

echo "✓ cyclonedds 编译安装完成"

echo ""
echo "步骤 2: 安装 unitree_sdk2_python..."
cd ~

if [ ! -d "unitree_sdk2_python" ]; then
    echo "克隆 unitree_sdk2_python 仓库..."
    git clone https://github.com/unitreerobotics/unitree_sdk2_python.git
else
    echo "✓ unitree_sdk2_python 目录已存在"
fi

cd unitree_sdk2_python

# 设置环境变量
export CYCLONEDDS_HOME="$CYCLONEDDS_INSTALL"
export CMAKE_PREFIX_PATH="$CYCLONEDDS_INSTALL:$CMAKE_PREFIX_PATH"
export LD_LIBRARY_PATH="$CYCLONEDDS_INSTALL/lib:$LD_LIBRARY_PATH"

echo "CYCLONEDDS_HOME=$CYCLONEDDS_HOME"
echo "安装中..."

if pip install -e .; then
    echo "✓ unitree_sdk2_python 安装成功"
else
    echo "❌ unitree_sdk2_python 安装失败"
    exit 1
fi

echo ""
echo "步骤 3: 修复 numpy 版本（如果需要）..."
pip install "numpy<2,>=1.26" --quiet 2>/dev/null || echo "numpy 版本可能正常"

echo ""
echo "步骤 4: 验证安装..."
if python -c "import unitree_sdk2py; print('✓ unitree_sdk2py 安装成功！')" 2>/dev/null; then
    echo ""
    echo "=========================================="
    echo "✅ 完成！所有组件已安装"
    echo "=========================================="
    echo ""
    echo "环境变量设置（添加到 ~/.bashrc 或 ~/.zshrc 以持久化）:"
    echo "export CYCLONEDDS_HOME=\"$CYCLONEDDS_INSTALL\""
    echo "export CMAKE_PREFIX_PATH=\"$CYCLONEDDS_INSTALL:\$CMAKE_PREFIX_PATH\""
    echo "export LD_LIBRARY_PATH=\"$CYCLONEDDS_INSTALL/lib:\$LD_LIBRARY_PATH\""
    echo ""
    echo "现在可以运行 demo 了！"
else
    echo "⚠️  验证失败，但可能仍然可以使用"
fi

