# 解决内存和 GPU 显存不足问题

## 问题症状

1. **CPU 模式运行时程序被杀死**
   - 终端显示 "已杀死"
   - Isaac Sim 显示"无响应"弹窗

2. **CUDA 模式运行时 GPU 显存不足**
   - `CUDA error: out of memory`
   - `Out of GPU memory allocating resource`
   - `Failed to get DOF velocities from backend`

## 解决方案

### 方案 1: 清理 GPU 显存（推荐）

```bash
# 检查 GPU 使用情况
nvidia-smi

# 如果有其他程序占用 GPU，先关闭它们
# 查看占用 GPU 的进程
fuser -v /dev/nvidia*

# 或者使用
sudo killall -9 python
sudo killall -9 kit
```

### 方案 2: 使用 Headless 模式（无 GUI，节省显存）

```bash
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

# 添加 --headless 参数
python sim_main.py \
    --device cuda:0 \
    --headless \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129
```

### 方案 3: 降低渲染设置

在运行命令前，可以设置环境变量来降低渲染质量：

```bash
export OMNI_KIT_GRAPHICS_QUALITY=low
export OMNI_KIT_RENDER_RESOLUTION=0.5  # 降低渲染分辨率

python sim_main.py \
    --device cuda:0 \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129
```

### 方案 4: 使用 CPU 模式但禁用相机

```bash
# 禁用相机可以减少内存使用
python sim_main.py \
    --device cpu \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129
# 注意：移除了 --enable_cameras
```

### 方案 5: 检查并释放系统内存

```bash
# 查看内存使用情况
free -h

# 清理系统缓存（需要 sudo）
sudo sync
sudo sysctl vm.drop_caches=3

# 关闭不必要的程序释放内存
```

### 方案 6: 重启系统（最后手段）

如果以上方法都不行，可能需要重启系统来清理所有资源。

## 推荐操作顺序

1. **先检查 GPU 使用情况** - 运行 `nvidia-smi`
2. **关闭其他 GPU 程序** - 关闭不必要的程序
3. **尝试 Headless 模式** - 这是最节省显存的方式
4. **如果还是不够，降低渲染质量** - 使用环境变量
5. **最后尝试 CPU 模式（无相机）** - 虽然慢，但可以运行

## 预防措施

- 运行前确保关闭其他占用 GPU 的程序
- 使用 `--headless` 模式进行开发和测试
- 需要查看可视化时再使用 GUI 模式
- 定期重启系统清理资源

## 快速命令

```bash
# 1. 检查并清理
nvidia-smi
sudo killall -9 kit python 2>/dev/null || true

# 2. 使用 headless 模式运行（推荐）
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

python sim_main.py \
    --device cuda:0 \
    --headless \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129
```

