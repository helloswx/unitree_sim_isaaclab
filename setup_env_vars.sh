#!/bin/bash
# 设置 cyclonedds 环境变量脚本

# 设置环境变量
export CYCLONEDDS_HOME="$HOME/cyclonedds/install"
export CMAKE_PREFIX_PATH="$HOME/cyclonedds/install:$CMAKE_PREFIX_PATH"
export LD_LIBRARY_PATH="$HOME/cyclonedds/install/lib:${LD_LIBRARY_PATH:-}"

# 确保动态库可以被找到
if [ -d "$HOME/cyclonedds/install/lib" ]; then
    export LD_LIBRARY_PATH="$HOME/cyclonedds/install/lib:$LD_LIBRARY_PATH"
    # 也添加到系统库路径
    if [ -f "$HOME/cyclonedds/install/lib/libddsc.so.0" ]; then
        echo "✓ cyclonedds 库文件已找到"
    fi
fi

echo "✓ 环境变量已设置"
echo "  CYCLONEDDS_HOME=$CYCLONEDDS_HOME"
echo "  LD_LIBRARY_PATH 包含: $HOME/cyclonedds/install/lib"

