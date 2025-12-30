# Git Push 解决方案

## 当前问题
推送卡住，可能原因：
1. 网络/代理问题
2. 仓库太大（55 个提交，.git 有 453M）
3. GitHub 服务器响应慢

## 解决方案

### 方案 1: 移除代理，直接推送（推荐先试这个）

```bash
# 移除代理
git config --global --unset http.proxy
git config --global --unset https.proxy

# 增加超时和缓冲区
git config --global http.postBuffer 524288000
git config --global http.timeout 600

# 推送
git push -u origin main
```

### 方案 2: 创建新分支，只推送最新提交

如果仓库历史太大，可以创建一个新分支只包含最新提交：

```bash
# 创建新分支，只包含当前提交
git checkout --orphan new-main
git add .
git commit -m "添加环境安装脚本和完整安装文档"

# 推送到新分支
git push -u origin new-main

# 然后在 GitHub 上设置 new-main 为默认分支
# 或者删除 main 分支，重命名 new-main 为 main
```

### 方案 3: 使用浅克隆方式推送

```bash
# 只推送最近的提交
git push -u origin main --depth=1
```

### 方案 4: 分批推送（如果有很多提交）

```bash
# 先推送较旧的提交
git push -u origin HEAD~10:main

# 再推送最新的
git push -u origin main
```

### 方案 5: 创建全新的干净仓库（最彻底）

如果以上都不行，可以创建一个全新的干净仓库：

```bash
# 1. 备份当前代码
cd ..
cp -r unitree_sim_isaaclab unitree_sim_isaaclab_backup

# 2. 删除 .git 目录
cd unitree_sim_isaaclab
rm -rf .git

# 3. 初始化新仓库
git init
git add .
git commit -m "初始提交：添加环境安装脚本和完整安装文档"

# 4. 添加远程仓库
# 注意：请将 YOUR_TOKEN_HERE 替换为你的 Personal Access Token
git remote add origin https://YOUR_TOKEN_HERE@github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# 5. 强制推送（因为是新仓库，可以强制）
git push -u origin main --force
```

### 方案 6: 使用 GitHub CLI（如果已安装）

```bash
# 安装 GitHub CLI（如果未安装）
# sudo apt install gh

# 登录
gh auth login

# 推送
git push -u origin main
```

## 推荐操作顺序

1. **先试方案 1**（移除代理，直接推送）
2. 如果还是卡住，试**方案 5**（创建全新干净仓库）
3. 如果都不行，检查网络连接和 GitHub 状态

## 检查网络

```bash
# 测试 GitHub 连接
curl -I https://github.com

# 测试代理
curl -I --proxy http://127.0.0.1:7890 https://github.com

# 测试带 token 的连接（请替换 YOUR_TOKEN_HERE 为你的 token）
curl -I -H "Authorization: token YOUR_TOKEN_HERE" https://api.github.com
```

## 注意事项

⚠️ **重要**: 你的 token 已经暴露在命令历史中，建议：
1. 推送成功后，立即在 GitHub 上撤销这个 token
2. 生成新的 token
3. 更新远程 URL（移除 token，使用凭据助手）

```bash
# 推送成功后，更新远程 URL（移除 token）
git remote set-url origin https://github.com/helloswx/unitree_sim_isaaclab.git

# 配置凭据助手
git config --global credential.helper store

# 下次推送时会提示输入用户名和 token
```

