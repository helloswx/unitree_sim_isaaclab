#!/bin/bash
# 杀死 Isaac Sim 和相关进程的脚本

echo "=========================================="
echo "正在终止 Isaac Sim 和相关进程..."
echo "=========================================="

# 1. 查找并杀死 sim_main.py 进程
echo ""
echo "查找 sim_main.py 进程..."
SIM_PIDS=$(pgrep -f "sim_main.py")
if [ -n "$SIM_PIDS" ]; then
    echo "找到 sim_main.py 进程: $SIM_PIDS"
    for pid in $SIM_PIDS; do
        echo "  终止进程 $pid..."
        kill -TERM $pid 2>/dev/null || kill -9 $pid 2>/dev/null
    done
    sleep 1
    # 确认是否还有残留
    REMAINING=$(pgrep -f "sim_main.py")
    if [ -n "$REMAINING" ]; then
        echo "  强制终止残留进程..."
        pkill -9 -f "sim_main.py"
    fi
else
    echo "  未找到 sim_main.py 进程"
fi

# 2. 查找并杀死 Isaac Sim (kit) 进程
echo ""
echo "查找 Isaac Sim (kit) 进程..."
KIT_PIDS=$(pgrep -f "kit")
if [ -n "$KIT_PIDS" ]; then
    echo "找到 kit 进程: $KIT_PIDS"
    for pid in $KIT_PIDS; do
        # 检查是否是 Isaac Sim 相关的 kit 进程
        if ps -p $pid -o args= | grep -q "isaaclab\|Isaac-Sim"; then
            echo "  终止 Isaac Sim kit 进程 $pid..."
            kill -TERM $pid 2>/dev/null || kill -9 $pid 2>/dev/null
        fi
    done
    sleep 1
    # 强制终止所有 kit 进程（如果还有残留）
    REMAINING=$(pgrep -f "kit.*isaaclab\|kit.*Isaac-Sim")
    if [ -n "$REMAINING" ]; then
        echo "  强制终止残留的 kit 进程..."
        pkill -9 -f "kit.*isaaclab\|kit.*Isaac-Sim"
    fi
else
    echo "  未找到 Isaac Sim kit 进程"
fi

# 3. 查找并杀死键盘控制脚本
echo ""
echo "查找键盘控制脚本进程..."
KEYBOARD_PIDS=$(pgrep -f "send_commands_keyboard.py")
if [ -n "$KEYBOARD_PIDS" ]; then
    echo "找到键盘控制进程: $KEYBOARD_PIDS"
    for pid in $KEYBOARD_PIDS; do
        echo "  终止进程 $pid..."
        kill -TERM $pid 2>/dev/null || kill -9 $pid 2>/dev/null
    done
else
    echo "  未找到键盘控制进程"
fi

# 4. 查找并杀死 8bit 控制器脚本
echo ""
echo "查找 8bit 控制器脚本进程..."
CONTROLLER_PIDS=$(pgrep -f "send_commands_8bit.py")
if [ -n "$CONTROLLER_PIDS" ]; then
    echo "找到 8bit 控制器进程: $CONTROLLER_PIDS"
    for pid in $CONTROLLER_PIDS; do
        echo "  终止进程 $pid..."
        kill -TERM $pid 2>/dev/null || kill -9 $pid 2>/dev/null
    done
else
    echo "  未找到 8bit 控制器进程"
fi

# 5. 查找并杀死 Python 进程（可能残留的）
echo ""
echo "检查是否有残留的 Python 进程..."
PYTHON_PIDS=$(pgrep -f "python.*sim_main\|python.*send_commands")
if [ -n "$PYTHON_PIDS" ]; then
    echo "找到残留的 Python 进程: $PYTHON_PIDS"
    for pid in $PYTHON_PIDS; do
        echo "  终止进程 $pid..."
        kill -TERM $pid 2>/dev/null || kill -9 $pid 2>/dev/null
    done
else
    echo "  未找到残留的 Python 进程"
fi

# 6. 等待一下，让进程完全退出
sleep 2

# 7. 最终检查
echo ""
echo "=========================================="
echo "最终检查..."
echo "=========================================="

REMAINING_SIM=$(pgrep -f "sim_main.py")
REMAINING_KIT=$(pgrep -f "kit.*isaaclab\|kit.*Isaac-Sim")
REMAINING_KEYBOARD=$(pgrep -f "send_commands_keyboard.py")
REMAINING_CONTROLLER=$(pgrep -f "send_commands_8bit.py")

if [ -z "$REMAINING_SIM" ] && [ -z "$REMAINING_KIT" ] && [ -z "$REMAINING_KEYBOARD" ] && [ -z "$REMAINING_CONTROLLER" ]; then
    echo "✅ 所有相关进程已成功终止"
else
    echo "⚠️  仍有残留进程:"
    [ -n "$REMAINING_SIM" ] && echo "  - sim_main.py: $REMAINING_SIM"
    [ -n "$REMAINING_KIT" ] && echo "  - kit: $REMAINING_KIT"
    [ -n "$REMAINING_KEYBOARD" ] && echo "  - send_commands_keyboard.py: $REMAINING_KEYBOARD"
    [ -n "$REMAINING_CONTROLLER" ] && echo "  - send_commands_8bit.py: $REMAINING_CONTROLLER"
    echo ""
    echo "如果需要强制终止，请运行:"
    echo "  pkill -9 -f 'sim_main.py|kit.*isaaclab|send_commands'"
fi

echo ""
echo "=========================================="
echo "完成！"
echo "=========================================="

