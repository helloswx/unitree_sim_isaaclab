# 性能优化指南

## 问题分析

从性能统计数据可以看到：
- **环境步骤（E）时间**: 2919.0ms - 这是主要瓶颈
- **动作时间（A）**: 0.2ms - 正常
- **模拟时间（S）**: 0.0ms - 正常
- **总时间（T）**: 2919.2ms
- **循环频率**: 从 13.36 Hz 降到 6.26 Hz，最近只有 0.34 Hz（约3秒/帧）

## 性能瓶颈原因

1. **渲染开销过大**（主要问题）
   - GUI 模式下需要渲染整个3D场景
   - 相机渲染（--enable_cameras）消耗大量GPU资源
   - 每帧都在等待渲染完成

2. **渲染频率过高**
   - 默认可能每步都渲染
   - 没有使用 `--render_interval` 降低渲染频率

3. **物理步长可能过小**
   - 默认 `physics_dt=0.005` 可能过小

## 优化方案

### 方案 1: 降低渲染频率（推荐）

使用 `--render_interval` 参数，每隔N步渲染一次：

```bash
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
source setup_env_vars.sh

python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --render_interval 10  # 每10步渲染一次
```

### 方案 2: 使用 Headless 模式（最省资源）

如果没有必要看GUI，使用无头模式：

```bash
python sim_main.py \
    --device cuda:0 \
    --headless \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129
```

### 方案 3: 禁用相机（如果不需要）

如果不需要相机数据，可以禁用：

```bash
python sim_main.py \
    --device cuda:0 \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129
# 移除 --enable_cameras
```

### 方案 4: 降低渲染质量

设置环境变量降低渲染质量：

```bash
export OMNI_KIT_GRAPHICS_QUALITY=low
export OMNI_KIT_RENDER_RESOLUTION=0.5

python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129
```

### 方案 5: 调整物理步长

增加物理步长可以减少计算次数：

```bash
python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --physics_dt 0.01  # 从 0.005 增加到 0.01
```

### 方案 6: 综合优化（最佳）

结合多种优化：

```bash
python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --render_interval 5 \
    --physics_dt 0.01 \
    --camera_write_interval 10
```

## 性能对比

| 配置 | 预期频率 | 说明 |
|------|---------|------|
| 默认GUI+相机 | 5-10 Hz | 当前状态 |
| render_interval=10 | 20-50 Hz | 推荐 |
| headless模式 | 50-100+ Hz | 最快 |
| 无相机 | 30-60 Hz | 较快 |

## 推荐配置

### 开发/测试（需要看到效果）

```bash
python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --render_interval 10
```

### 数据生成（不需要GUI）

```bash
python sim_main.py \
    --device cuda:0 \
    --headless \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --generate_data
```

### 训练（性能优先）

```bash
python sim_main.py \
    --device cuda:0 \
    --headless \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --physics_dt 0.01 \
    --render_interval 0  # 禁用渲染更新
```

## 快速优化命令

创建一个优化版本的运行脚本，自动应用这些优化。

