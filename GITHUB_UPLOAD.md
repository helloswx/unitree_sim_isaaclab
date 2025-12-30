# 上传到 GitHub 指南

本指南说明如何将项目上传到你的 GitHub 仓库。

## 前置准备

1. **GitHub 账户**: 确保你已有 GitHub 账户
2. **Git 配置**: 配置你的 Git 用户信息（如果还未配置）

```bash
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

## 上传步骤

### 方法一：上传到新仓库（推荐）

1. **在 GitHub 上创建新仓库**
   - 访问 https://github.com/new
   - 填写仓库名称（例如：`unitree_sim_isaaclab`）
   - 选择 Public 或 Private
   - **不要**勾选 "Initialize this repository with a README"（因为本地已有）
   - 点击 "Create repository"

2. **检查当前仓库状态**

```bash
cd /home/bz/桌面/playground/unitree_sim_isaaclab
git status
```

3. **添加新文件到 Git**

```bash
# 添加安装相关的脚本和文档
git add setup_environment.sh
git add check_system.sh
git add INSTALLATION_zh.md
git add QUICKSTART_zh.md
git add INSTALL_GUIDE_zh.md
git add GITHUB_UPLOAD.md

# 或者添加所有新文件（推荐）
git add .

# 查看将要提交的文件
git status
```

4. **提交更改**

```bash
git commit -m "添加环境安装脚本和完整安装文档

- 添加自动安装脚本 setup_environment.sh
- 添加系统检查脚本 check_system.sh
- 添加完整安装指南 INSTALLATION_zh.md
- 添加快速开始指南 QUICKSTART_zh.md
- 更新 README 添加安装文档链接"
```

5. **添加远程仓库并推送**

```bash
# 替换 YOUR_USERNAME 和 YOUR_REPO_NAME 为你的实际值
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# 或者使用 SSH（如果已配置 SSH key）
# git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPO_NAME.git

# 推送到 GitHub
git push -u origin main
```

如果遇到错误，可能需要先拉取：

```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

### 方法二：如果已有远程仓库

如果项目已经连接到远程仓库，只需要：

```bash
git add .
git commit -m "添加环境安装脚本和完整安装文档"
git push
```

## 验证上传

1. 访问你的 GitHub 仓库页面
2. 确认以下文件已上传：
   - ✅ `setup_environment.sh`
   - ✅ `check_system.sh`
   - ✅ `INSTALLATION_zh.md`
   - ✅ `QUICKSTART_zh.md`
   - ✅ `README_zh-CN.md`（已更新）

## 后续更新

以后如果有更改，使用以下命令：

```bash
git add .
git commit -m "描述你的更改"
git push
```

## 注意事项

1. **不要提交敏感信息**：
   - API keys
   - 密码
   - 个人配置文件
   - 大型数据文件

2. **检查 .gitignore**：
   - 确保 `.gitignore` 文件正确配置
   - 避免提交不必要的文件（如 `__pycache__`, `.pyc` 等）

3. **大文件处理**：
   - 如果仓库中有大文件，考虑使用 Git LFS
   - 或者将大文件放在 `.gitignore` 中

4. **分支管理**（可选）：
   ```bash
   # 创建开发分支
   git checkout -b dev
   git push -u origin dev
   ```

## 常见问题

### 1. 推送被拒绝（Push rejected）

如果提示需要先拉取：

```bash
git pull origin main --rebase
git push -u origin main
```

### 2. 认证问题

如果遇到认证问题，可以：

- 使用 Personal Access Token（推荐）
- 配置 SSH key
- 使用 GitHub CLI

### 3. 文件太大

如果某些文件太大无法推送：

```bash
# 查看大文件
git ls-files | xargs du -h | sort -rh | head -20

# 从 Git 中移除但保留本地文件
git rm --cached 大文件路径
git commit -m "移除大文件"
git push
```

## 参考资源

- [Git 官方文档](https://git-scm.com/doc)
- [GitHub 帮助文档](https://docs.github.com/)
- [Git 教程](https://www.atlassian.com/git/tutorials)

