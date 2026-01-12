#!/bin/bash
# 修复 Git 历史中的 token

set -e

echo "=========================================="
echo "修复 Git 历史中的敏感 token"
echo "=========================================="

# 备份当前分支
echo ""
echo "备份当前分支..."
git branch backup-before-fix 2>/dev/null || true
echo "✓ 已创建备份分支: backup-before-fix"

# 使用 git filter-branch 替换历史中的 token
echo ""
echo "正在修复历史提交中的 token..."
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch PUSH_SOLUTIONS.md create_clean_repo.sh 2>/dev/null || true' \
  --prune-empty --tag-name-filter cat -- --all

# 重新添加修复后的文件
echo ""
echo "重新添加修复后的文件..."
git add PUSH_SOLUTIONS.md create_clean_repo.sh
git commit -m "修复：移除代码中的敏感 token 信息" --allow-empty 2>/dev/null || true

echo ""
echo "=========================================="
echo "修复完成！"
echo "=========================================="
echo ""
echo "现在可以尝试推送："
echo "  git push -u origin main --force"
echo ""
echo "⚠️  注意: 这会重写历史，如果已经推送过，需要使用 --force"
echo "   如果其他人已经克隆了仓库，他们需要重新克隆"

