# 手动下载资产文件指南

如果 `fetch_assets.sh` 脚本因为网络问题无法运行，可以手动下载资产文件。

## 方法 1: 使用 Git 手动克隆（推荐）

```bash
cd ~/桌面/playground/unitree_sim_isaaclab

# 1. 初始化 Git LFS
git lfs install

# 2. 设置代理（如果使用代理）
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890

# 3. 克隆仓库
git clone https://huggingface.co/datasets/unitreerobotics/unitree_sim_isaaclab_usds

# 4. 进入目录并解压
cd unitree_sim_isaaclab_usds
unzip assets.zip

# 5. 移动 assets 文件夹到项目根目录
mv assets ../

# 6. 返回并清理
cd ..
rm -rf unitree_sim_isaaclab_usds
```

## 方法 2: 使用 Hugging Face CLI

```bash
# 安装 Hugging Face CLI
pip install huggingface_hub

# 下载数据集
huggingface-cli download unitreerobotics/unitree_sim_isaaclab_usds --local-dir ./unitree_sim_isaaclab_usds

# 解压并移动
cd unitree_sim_isaaclab_usds
unzip assets.zip
mv assets ../
cd ..
rm -rf unitree_sim_isaaclab_usds
```

## 方法 3: 浏览器下载

1. 访问: https://huggingface.co/datasets/unitreerobotics/unitree_sim_isaaclab_usds
2. 下载 `assets.zip` 文件
3. 将文件放到项目根目录
4. 解压:
   ```bash
   cd ~/桌面/playground/unitree_sim_isaaclab
   unzip assets.zip
   ```

## 网络问题排查

### 如果遇到连接被重置

1. **检查网络连接**
   ```bash
   ping huggingface.co
   ```

2. **使用代理**
   ```bash
   git config --global http.proxy http://127.0.0.1:7890
   git config --global https.proxy http://127.0.0.1:7890
   ```

3. **使用镜像（如果有）**

4. **重试**
   ```bash
   # 删除失败的克隆
   rm -rf unitree_sim_isaaclab_usds
   # 重新运行脚本
   bash fetch_assets.sh
   ```

## 验证下载

下载完成后，检查 assets 文件夹：

```bash
cd ~/桌面/playground/unitree_sim_isaaclab
ls -lh assets/
```

应该能看到各种 USD 模型文件。

