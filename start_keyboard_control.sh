#!/bin/bash
# 启动键盘控制脚本

echo "=========================================="
echo "启动键盘控制程序"
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

# 3. 检查是否有 sim_main.py 在运行
if ! pgrep -f "sim_main.py" > /dev/null; then
    echo ""
    echo "⚠️  警告: 未检测到 sim_main.py 进程"
    echo "请先启动仿真程序，然后再运行此脚本"
    echo ""
    read -p "是否继续？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 4. 检查是否已经运行了键盘控制
if pgrep -f "send_commands_keyboard.py" > /dev/null; then
    echo ""
    echo "⚠️  检测到键盘控制程序已在运行"
    echo "PID: $(pgrep -f 'send_commands_keyboard.py')"
    read -p "是否终止旧进程并重新启动？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pkill -f "send_commands_keyboard.py"
        sleep 1
    else
        echo "退出"
        exit 0
    fi
fi

# 5. 检查 pynput 库
echo ""
echo "检查依赖..."
python3 -c "import pynput" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ 缺少 pynput 库"
    echo "正在安装..."
    pip install pynput
    if [ $? -ne 0 ]; then
        echo "❌ 安装失败，请手动运行: pip install pynput"
        exit 1
    fi
fi

# 6. 显示控制说明
echo ""
echo "=========================================="
echo "键盘控制说明"
echo "=========================================="
echo "W: 前进    S: 后退"
echo "A: 左移    D: 右移"
echo "Z: 左转    X: 右转"
echo "C: 下蹲    Q: 退出程序"
echo ""
echo "提示: 按住按键可以持续控制"
echo "=========================================="
echo ""

# 7. 启动键盘控制
echo "启动键盘控制程序..."
echo "注意: 请确保 Isaac Sim 窗口已激活，并且任务类型是 Wholebody"
echo ""

python send_commands_keyboard.py

