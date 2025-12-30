#!/bin/bash
# 创建全新的干净仓库脚本

set -e

echo "=========================================="
echo "创建全新的干净 Git 仓库"
echo "=========================================="
echo ""
echo "⚠️  警告: 这将删除当前的 .git 目录，创建一个全新的仓库"
echo "   只会保留当前工作目录的文件"
echo ""
read -p "确认继续? (y/n) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

# 备份当前 .git（以防万一）
if [ -d .git ]; then
    echo ""
    echo "备份当前 .git 目录..."
    cp -r .git .git_backup_$(date +%Y%m%d_%H%M%S)
    echo "✓ 已备份到 .git_backup_*"
fi

# 删除 .git
echo ""
echo "删除旧的 .git 目录..."
rm -rf .git
echo "✓ 已删除"

# 初始化新仓库
echo ""
echo "初始化新 Git 仓库..."
git init
echo "✓ 已初始化"

# 添加所有文件
echo ""
echo "添加文件..."
git add .
echo "✓ 已添加"

# 提交
echo ""
echo "创建初始提交..."
git commit -m "初始提交：添加环境安装脚本和完整安装文档

- 添加自动安装脚本 setup_environment.sh（支持 RTX 50 系列显卡）
- 添加系统检查脚本 check_system.sh
- 添加完整安装指南 INSTALLATION_zh.md
- 添加快速开始指南 QUICKSTART_zh.md
- 更新 README_zh-CN.md 添加安装文档链接
- 更新 .gitignore 排除安装包等文件"
echo "✓ 已提交"

# 设置远程仓库
echo ""
echo "设置远程仓库..."
read -p "GitHub 用户名: " GITHUB_USER
read -p "仓库名称: " REPO_NAME
read -sp "Personal Access Token (输入时不会显示): " GITHUB_TOKEN
echo ""
REMOTE_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"
git remote add origin "$REMOTE_URL"
echo "✓ 已设置远程仓库"

# 配置 Git
echo ""
echo "配置 Git..."
git config --global http.postBuffer 524288000
git config --global http.timeout 600
echo "✓ 已配置"

echo ""
echo "=========================================="
echo "准备完成！"
echo "=========================================="
echo ""
echo "现在可以推送了："
echo "  git push -u origin main --force"
echo ""
read -p "是否现在推送? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "开始推送..."
    git push -u origin main --force
    echo ""
    echo "✓ 推送完成！"
    echo ""
    echo "⚠️  重要: 推送成功后，请立即："
    echo "  1. 在 GitHub 上撤销当前 token（已暴露在命令中）"
    echo "  2. 生成新的 token"
    echo "  3. 更新远程 URL: git remote set-url origin https://github.com/helloswx/unitree_sim_isaaclab.git"
else
    echo "稍后可以运行: git push -u origin main --force"
fi

