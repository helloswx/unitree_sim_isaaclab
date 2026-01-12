# 安装 unitree_sdk2_python 指南

## 问题

安装 `unitree_sdk2_python` 时遇到 `cyclonedds` 依赖问题。

## 解决方案

### 步骤 1: 安装系统依赖

在终端中运行（需要 sudo 权限）：

```bash
sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    libssl-dev \
    libxml2-dev \
    pkg-config
```

### 步骤 2: 安装 unitree_sdk2_python

```bash
# 激活环境
conda activate unitree_sim_env

# 如果还未克隆，先克隆
cd ~
git clone https://github.com/unitreerobotics/unitree_sdk2_python.git
cd unitree_sdk2_python

# 安装
pip install -e .
```

### 步骤 3: 验证安装

```bash
python -c "import unitree_sdk2py; print('✓ unitree_sdk2py 安装成功')"
```

## 如果仍然遇到 cyclonedds 问题

### 方法 A: 手动安装 cyclonedds

```bash
# 安装 cyclonedds C 库
sudo apt install -y libcyclonedds-dev

# 或者从源码编译
cd ~
git clone https://github.com/eclipse-cyclonedds/cyclonedds.git
cd cyclonedds
mkdir build && cd build
cmake ..
make
sudo make install

# 设置环境变量
export CYCLONEDDS_HOME=/usr/local
export CMAKE_PREFIX_PATH=/usr/local:$CMAKE_PREFIX_PATH

# 然后重新安装
cd ~/unitree_sdk2_python
pip install -e .
```

### 方法 B: 使用预编译版本（如果有）

查看 unitree_sdk2_python 的 GitHub 仓库，看是否有预编译的 wheel 文件。

### 方法 C: 参考官方 FAQ

访问 [unitree_sdk2_python FAQ](https://github.com/unitreerobotics/unitree_sdk2_python?tab=readme-ov-file#faq) 获取更多解决方案。

## 快速安装脚本

你也可以运行以下命令（需要 sudo 权限）：

```bash
# 安装系统依赖
sudo apt update && sudo apt install -y build-essential cmake libssl-dev libxml2-dev pkg-config

# 激活环境并安装
conda activate unitree_sim_env
cd ~
if [ ! -d "unitree_sdk2_python" ]; then
    git clone https://github.com/unitreerobotics/unitree_sdk2_python.git
fi
cd unitree_sdk2_python
pip install -e .
```

## 验证

安装完成后，运行：

```bash
conda activate unitree_sim_env
python -c "import unitree_sdk2py; print('安装成功！')"
```

然后就可以运行 demo 了：

```bash
cd ~/桌面/playground/unitree_sim_isaaclab
python sim_main.py \
    --device cpu \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129
```

