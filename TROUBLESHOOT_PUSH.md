# Git Push 问题排查指南

## 问题：git push 卡住不动

### 可能的原因和解决方案

#### 1. 认证问题（最常见）

GitHub 现在要求使用 Personal Access Token 而不是密码。

**解决方法 A: 使用 Personal Access Token**

1. 生成 Token：
   - 访问：https://github.com/settings/tokens
   - 点击 "Generate new token (classic)"
   - 选择权限：至少勾选 `repo`
   - 生成并复制 token

2. 推送时使用 token：
   ```bash
   # 当提示输入密码时，输入 token（不是密码）
   git push -u origin main
   ```

**解决方法 B: 使用 SSH（推荐）**

1. 检查是否有 SSH key：
   ```bash
   ls -la ~/.ssh/id_rsa.pub
   ```

2. 如果没有，生成 SSH key：
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   # 按 Enter 使用默认路径
   # 可以设置密码或直接 Enter
   ```

3. 添加 SSH key 到 GitHub：
   ```bash
   cat ~/.ssh/id_rsa.pub
   # 复制输出内容
   ```
   - 访问：https://github.com/settings/keys
   - 点击 "New SSH key"
   - 粘贴内容并保存

4. 更改远程 URL 为 SSH：
   ```bash
   git remote set-url origin git@github.com:helloswx/unitree_sim_isaaclab.git
   git push -u origin main
   ```

#### 2. 代理问题

如果使用代理，确保配置正确：

```bash
# 检查代理配置
git config --global --get http.proxy
git config --global --get https.proxy

# 如果代理不对，重新设置
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890

# 或者如果代理有问题，临时取消
git config --global --unset http.proxy
git config --global --unset https.proxy
```

#### 3. 大文件问题

如果仓库中有大文件，GitHub 可能拒绝推送。

**检查大文件：**
```bash
# 查看最大的文件
git ls-files | xargs du -h | sort -rh | head -20

# 查看 .git 目录大小
du -sh .git
```

**解决方法：**
- 如果文件 > 100MB，考虑使用 Git LFS
- 或者从历史中移除大文件（需要重写历史）

#### 4. 网络超时

增加超时时间：

```bash
git config --global http.postBuffer 524288000
git config --global http.timeout 300
```

#### 5. 使用详细模式查看问题

```bash
# 使用详细模式推送，查看具体卡在哪里
GIT_CURL_VERBOSE=1 GIT_TRACE=1 git push -u origin main
```

#### 6. 分批推送（如果有很多提交）

```bash
# 只推送最近的几个提交
git push -u origin HEAD~5:main  # 先推送较旧的提交
git push -u origin main          # 再推送最新的
```

#### 7. 强制推送（谨慎使用）

如果确定要覆盖远程：

```bash
git push -u origin main --force
```

## 推荐的完整流程

### 方法 1: 使用 SSH（最稳定）

```bash
# 1. 检查 SSH key
ls -la ~/.ssh/id_rsa.pub

# 2. 如果没有，生成（已有可跳过）
ssh-keygen -t ed25519 -C "your_email@example.com"

# 3. 复制公钥并添加到 GitHub
cat ~/.ssh/id_rsa.pub

# 4. 测试连接
ssh -T git@github.com

# 5. 更改远程 URL
git remote set-url origin git@github.com:helloswx/unitree_sim_isaaclab.git

# 6. 推送
git push -u origin main
```

### 方法 2: 使用 HTTPS + Token

```bash
# 1. 确保远程 URL 正确
git remote set-url origin https://github.com/helloswx/unitree_sim_isaaclab.git

# 2. 配置凭据助手（可选）
git config --global credential.helper store

# 3. 推送（会提示输入用户名和 token）
git push -u origin main
# 用户名: helloswx
# 密码: <粘贴你的 Personal Access Token>
```

## 快速诊断命令

```bash
# 检查远程仓库
git remote -v

# 检查网络连接
curl -I https://github.com

# 检查代理
echo $http_proxy
echo $https_proxy

# 检查 Git 配置
git config --list | grep -E "(proxy|url|user)"
```

