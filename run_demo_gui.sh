#!/bin/bash
# GUI 模式运行 demo 脚本（带相机）

echo "=========================================="
echo "Unitree Sim IsaacLab Demo - GUI 模式"
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

# 3. 清理旧进程
echo ""
echo "清理可能的残留进程..."
pkill -f "sim_main.py" 2>/dev/null || true
pkill -f "kit" 2>/dev/null || true
sleep 1

# 4. 检查 GPU 显存
echo ""
echo "GPU 显存状态:"
nvidia-smi --query-gpu=memory.free,memory.total --format=csv,noheader,nounits | awk '{print "  可用: "$1"MB / 总计: "$2"MB"}'

# 5. 运行 demo（GUI 模式 + 相机）
echo ""
echo "=========================================="
echo "启动 Demo (GUI 模式)..."
echo "=========================================="
echo ""

python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    "$@"

