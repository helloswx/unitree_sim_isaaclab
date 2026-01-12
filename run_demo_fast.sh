#!/bin/bash
# 高性能运行 demo 脚本（优化性能）

echo "=========================================="
echo "Unitree Sim IsaacLab Demo - 性能优化模式"
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

# 5. 选择运行模式
echo ""
echo "选择运行模式:"
echo "1) GUI 模式 + 性能优化 (推荐，平衡性能和可视化)"
echo "2) Headless 模式 (最快，无GUI)"
echo "3) GUI 模式 + 完整渲染 (最慢，但视觉效果最好)"
read -p "请选择 (1/2/3) [默认: 1]: " MODE
MODE=${MODE:-1}

case $MODE in
    1)
        echo ""
        echo "=========================================="
        echo "启动 Demo (GUI 模式 + 性能优化)..."
        echo "=========================================="
        echo "优化设置:"
        echo "  - 渲染间隔: 每10步渲染一次"
        echo "  - 物理步长: 0.01s"
        echo "  - 相机写入间隔: 每10步一次"
        echo ""
        
        python sim_main.py \
            --device cuda:0 \
            --enable_cameras \
            --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
            --enable_dex1_dds \
            --robot_type g129 \
            --render_interval 10 \
            --physics_dt 0.01 \
            --camera_write_interval 10 \
            "$@"
        ;;
    2)
        echo ""
        echo "=========================================="
        echo "启动 Demo (Headless 模式 - 最快)..."
        echo "=========================================="
        echo "优化设置:"
        echo "  - 无GUI渲染"
        echo "  - 物理步长: 0.01s"
        echo ""
        
        python sim_main.py \
            --device cuda:0 \
            --headless \
            --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
            --enable_dex1_dds \
            --robot_type g129 \
            --physics_dt 0.01 \
            "$@"
        ;;
    3)
        echo ""
        echo "=========================================="
        echo "启动 Demo (GUI 模式 + 完整渲染)..."
        echo "=========================================="
        echo "警告: 此模式性能较低，可能只有 5-10 Hz"
        echo ""
        
        python sim_main.py \
            --device cuda:0 \
            --enable_cameras \
            --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
            --enable_dex1_dds \
            --robot_type g129 \
            "$@"
        ;;
    *)
        echo "无效选择，使用模式1"
        exit 1
        ;;
esac

