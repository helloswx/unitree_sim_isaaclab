#!/bin/bash
# 安全运行 demo 脚本 - 自动清理进程和设置环境变量

echo "=========================================="
echo "Unitree Sim IsaacLab Demo 启动脚本"
echo "=========================================="

# 1. 激活环境
if [ -z "$CONDA_DEFAULT_ENV" ] || [ "$CONDA_DEFAULT_ENV" != "unitree_sim_env" ]; then
    echo "激活 conda 环境..."
    source ~/miniconda3/etc/profile.d/conda.sh
    conda activate unitree_sim_env
fi

# 2. 设置环境变量
cd ~/桌面/playground/unitree_sim_isaaclab
source setup_env_vars.sh

# 3. 检查并清理旧的进程
echo ""
echo "检查 GPU 使用情况..."
GPU_PROCESSES=$(nvidia-smi --query-compute-apps=pid --format=csv,noheader 2>/dev/null | tr '\n' ' ')
if [ -n "$GPU_PROCESSES" ]; then
    echo "发现 GPU 进程: $GPU_PROCESSES"
    read -p "是否清理这些进程? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "清理 GPU 进程..."
        for pid in $GPU_PROCESSES; do
            kill -9 $pid 2>/dev/null || true
        done
        sleep 2
    fi
fi

# 4. 清理可能的残留进程
echo "清理可能的残留进程..."
pkill -f "sim_main.py" 2>/dev/null || true
pkill -f "kit" 2>/dev/null || true
sleep 1

# 5. 检查 GPU 显存
echo ""
echo "GPU 显存状态:"
nvidia-smi --query-gpu=memory.free,memory.total --format=csv,noheader,nounits | awk '{print "  可用: "$1"MB / 总计: "$2"MB"}'

# 6. 运行 demo（使用 headless 模式以节省显存）
echo ""
echo "=========================================="
echo "启动 Demo..."
echo "=========================================="
echo ""
echo "提示："
echo "  - 如果 GPU 显存不足，会自动使用 --headless 模式"
echo "  - 使用 Ctrl+C 停止"
echo ""

# 检查显存是否充足（至少需要 8GB 可用）
FREE_MEM=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits | head -1)
if [ "$FREE_MEM" -lt 8000 ]; then
    echo "⚠️  GPU 显存不足，使用 headless 模式..."
    HEADLESS_FLAG="--headless"
else
    echo "✓ GPU 显存充足，可以使用 GUI 模式"
    HEADLESS_FLAG=""
fi

# 运行命令
# 如果是 GUI 模式，需要添加 --enable_cameras
if [ -z "$HEADLESS_FLAG" ]; then
    CAMERA_FLAG="--enable_cameras"
else
    CAMERA_FLAG=""
fi

python sim_main.py \
    --device cuda:0 \
    $HEADLESS_FLAG \
    $CAMERA_FLAG \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    "$@"

