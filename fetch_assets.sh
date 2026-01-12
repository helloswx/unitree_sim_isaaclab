#!/bin/bash

# 使用更温和的错误处理
set -o pipefail

# 错误处理函数
handle_error() {
    echo ""
    echo "❌ 错误: $1"
    echo ""
    echo "可能的解决方案:"
    echo "1. 检查网络连接"
    echo "2. 如果使用代理，设置 Git 代理:"
    echo "   git config --global http.proxy http://127.0.0.1:7890"
    echo "   git config --global https.proxy http://127.0.0.1:7890"
    echo "3. 或者使用 Hugging Face 镜像"
    echo "4. 手动下载: 访问 https://huggingface.co/datasets/unitreerobotics/unitree_sim_isaaclab_usds"
    exit 1
}

# 1. Clone repository
echo "=========================================="
echo "下载资产文件"
echo "=========================================="
echo ""
echo "步骤 1: 初始化 Git LFS..."
if ! git lfs install; then
    handle_error "Git LFS 初始化失败"
fi

echo ""
echo "步骤 2: 克隆仓库（这可能需要一些时间）..."
if [ -d "unitree_sim_isaaclab_usds" ]; then
    echo "⚠️  检测到已存在的 unitree_sim_isaaclab_usds 目录"
    read -p "是否删除并重新下载? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf unitree_sim_isaaclab_usds
    else
        echo "使用现有目录"
        cd unitree_sim_isaaclab_usds
        skip_clone=true
    fi
fi

if [ "$skip_clone" != "true" ]; then
    if ! git clone https://huggingface.co/datasets/unitreerobotics/unitree_sim_isaaclab_usds; then
        handle_error "克隆仓库失败，可能是网络问题"
    fi
    cd unitree_sim_isaaclab_usds
fi

# 2. Enter repository directory
cd unitree_sim_isaaclab_usds

# 3. Check if assets.zip exists and is greater than 1GB
echo ""
echo "步骤 3: 检查 assets.zip 文件..."
if [ ! -f "assets.zip" ]; then
    handle_error "assets.zip 文件不存在"
fi

filesize=$(stat -c%s "assets.zip" 2>/dev/null || echo "0")
if [ "$filesize" -le $((1024 * 1024 * 1024)) ]; then
    echo "⚠️  警告: assets.zip 文件大小小于 1GB，可能下载不完整"
    echo "文件大小: $((filesize / 1024 / 1024)) MB"
    read -p "是否继续? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        handle_error "用户取消操作"
    fi
else
    echo "✓ assets.zip 检查通过，大小: $((filesize / 1024 / 1024)) MB"
fi

# 4. Unzip assets.zip
echo ""
echo "步骤 4: 解压 assets.zip（这可能需要一些时间）..."
if ! unzip -q assets.zip; then
    handle_error "解压 assets.zip 失败"
fi

# 5. Move assets folder to parent directory
echo ""
echo "步骤 5: 移动 assets 文件夹..."
if [ -d "assets" ]; then
    if [ -d "../assets" ]; then
        echo "⚠️  检测到已存在的 assets 目录"
        read -p "是否覆盖? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf ../assets
            mv assets ../
            echo "✓ assets 文件夹已移动"
        else
            echo "保留现有 assets 目录"
        fi
    else
    mv assets ../
        echo "✓ assets 文件夹已移动"
    fi
else
    handle_error "解压后 assets 文件夹不存在"
fi

# 6. Return to parent directory and delete original folder
cd ..
echo ""
echo "步骤 6: 清理临时文件..."
if [ -d "unitree_sim_isaaclab_usds" ]; then
rm -rf unitree_sim_isaaclab_usds
    echo "✓ 临时文件已清理"
fi

echo ""
echo "=========================================="
echo "✅ 完成！资产文件已下载并解压"
echo "=========================================="
