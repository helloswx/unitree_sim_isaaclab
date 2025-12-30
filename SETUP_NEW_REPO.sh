#!/bin/bash
# 设置新 GitHub 仓库的脚本

echo "=========================================="
echo "设置新的 GitHub 仓库"
echo "=========================================="

# 检查 Git 配置
echo ""
echo "当前 Git 配置:"
echo "  用户名: $(git config --global user.name)"
echo "  邮箱: $(git config --global user.email)"

# 检查远程仓库
echo ""
echo "当前远程仓库:"
git remote -v

if [ -n "$(git remote)" ]; then
    echo ""
    read -p "检测到已有远程仓库，是否移除? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote remove origin
        echo "✓ 已移除旧的远程仓库"
    fi
fi

# 获取新仓库信息
echo ""
echo "=========================================="
echo "请提供新仓库信息:"
echo "=========================================="
read -p "GitHub 用户名: " GITHUB_USER
read -p "仓库名称 (例如: unitree_sim_isaaclab): " REPO_NAME

# 选择协议
echo ""
echo "选择连接方式:"
echo "  1) HTTPS (推荐，简单)"
echo "  2) SSH (需要配置 SSH key)"
read -p "请选择 (1/2): " PROTOCOL

if [ "$PROTOCOL" == "2" ]; then
    REPO_URL="git@github.com:${GITHUB_USER}/${REPO_NAME}.git"
else
    REPO_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
fi

echo ""
echo "将添加远程仓库: ${REPO_URL}"
read -p "确认添加? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    git remote add origin "$REPO_URL"
    echo "✓ 已添加远程仓库"
    echo ""
    echo "下一步:"
    echo "  1. 在 GitHub 上创建仓库: https://github.com/new"
    echo "  2. 仓库名称: ${REPO_NAME}"
    echo "  3. 不要初始化 README（本地已有）"
    echo "  4. 创建后运行: git push -u origin main"
else
    echo "已取消"
fi

