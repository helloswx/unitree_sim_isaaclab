# 解决 cyclonedds 安装问题

## 问题

安装 `unitree_sdk2_python` 时，`cyclonedds` Python 包无法找到 cyclonedds C 库。

## 解决方案

### 方法 1: 安装系统包（最简单，推荐）

```bash
# 安装 cyclonedds 开发库
sudo apt update
sudo apt install -y cyclonedds-dev

# 然后安装 unitree_sdk2_python
conda activate unitree_sim_env
cd ~/unitree_sdk2_python
pip install -e .
```

### 方法 2: 从源码编译 cyclonedds（如果方法 1 不行）

```bash
# 1. 安装依赖
sudo apt install -y \
    build-essential \
    cmake \
    libssl-dev \
    libxml2-dev \
    pkg-config \
    libcunit1-dev

# 2. 克隆并编译 cyclonedds
cd ~
git clone https://github.com/eclipse-cyclonedds/cyclonedds.git
cd cyclonedds
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
make -j$(nproc)
sudo make install

# 3. 设置环境变量
export CYCLONEDDS_HOME=/usr/local
export CMAKE_PREFIX_PATH=/usr/local:$CMAKE_PREFIX_PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# 4. 安装 unitree_sdk2_python
conda activate unitree_sim_env
cd ~/unitree_sdk2_python
pip install -e .
```

### 方法 3: 使用 conda 安装（如果可用）

```bash
conda activate unitree_sim_env
conda install -c conda-forge cyclonedds -y
cd ~/unitree_sdk2_python
pip install -e .
```

### 方法 4: 检查 cyclonedds 安装位置

如果已经安装了 cyclonedds，但 pip 找不到，可以：

```bash
# 查找 cyclonedds 库文件
find /usr -name "*cyclonedds*" 2>/dev/null | head -5

# 查找头文件
find /usr -name "dds.h" 2>/dev/null | head -5

# 根据找到的路径设置环境变量
# 例如，如果找到 /usr/lib/x86_64-linux-gnu/libddsc.so
export CYCLONEDDS_HOME=/usr
export CMAKE_PREFIX_PATH=/usr:$CMAKE_PREFIX_PATH
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
```

## 验证安装

安装完成后，验证：

```bash
conda activate unitree_sim_env
python -c "import unitree_sdk2py; print('✓ 安装成功！')"
```

## 推荐操作顺序

1. **先试方法 1**（最简单）
2. 如果不行，试**方法 2**（从源码编译）
3. 如果还是不行，查看 [unitree_sdk2_python FAQ](https://github.com/unitreerobotics/unitree_sdk2_python#faq)

## 完整安装命令（方法 1）

```bash
# 安装 cyclonedds 开发库
sudo apt update
sudo apt install -y cyclonedds-dev

# 安装 unitree_sdk2_python
conda activate unitree_sim_env
cd ~/unitree_sdk2_python
pip install -e .

# 验证
python -c "import unitree_sdk2py; print('成功！')"
```

