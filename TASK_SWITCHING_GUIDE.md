# 🔄 任务切换指南

## 关于任务切换

### ❓ 每次切换任务都需要重新打开 Isaac Sim 吗？

**答案：是的，需要重新启动。**

**原因：**
1. **不同的任务使用不同的环境配置**：每个任务（如 `Isaac-PickPlace-Cylinder-G129-Dex1-Joint`、`Isaac-Move-Cylinder-G129-Dex1-Wholebody`）都有自己独特的场景配置、机器人设置、物体位置等
2. **Isaac Sim 在启动时加载场景**：场景是在 `sim_main.py` 启动时根据 `--task` 参数加载的，不能在运行时动态切换
3. **环境重置机制**：虽然代码中有 `env.reset()` 功能，但这只是重置当前任务的初始状态，不能切换到完全不同的任务

### ✅ 正确的切换方式

**步骤：**

1. **终止当前任务**
   ```bash
   # 使用提供的脚本
   bash kill_sim.sh
   
   # 或者手动终止
   pkill -f "sim_main.py"
   ```

2. **启动新任务**
   ```bash
   cd ~/桌面/playground/unitree_sim_isaaclab
   conda activate unitree_sim_env
   source setup_env_vars.sh
   
   python sim_main.py \
       --device cuda:0 \
       --enable_cameras \
       --task <新任务名称> \
       --enable_dex1_dds \
       --robot_type g129 \
       --render_interval 10
   ```

### 📋 可用的任务列表

#### G1 机器人任务

**Joint 任务（固定位置）：**
- `Isaac-PickPlace-Cylinder-G129-Dex1-Joint` - 抓取圆柱体（二指夹爪）
- `Isaac-PickPlace-Cylinder-G129-Dex3-Joint` - 抓取圆柱体（三指灵巧手）
- `Isaac-PickPlace-Cylinder-G129-Inspire-Joint` - 抓取圆柱体（Inspire 手）
- `Isaac-PickPlace-RedBlock-G129-Dex1-Joint` - 抓取红色木块（二指夹爪）
- `Isaac-PickPlace-RedBlock-G129-Dex3-Joint` - 抓取红色木块（三指灵巧手）
- `Isaac-PickPlace-RedBlock-G129-Inspire-Joint` - 抓取红色木块（Inspire 手）
- `Isaac-Stack-RgyBlock-G129-Dex1-Joint` - 堆叠彩色木块（二指夹爪）
- `Isaac-Stack-RgyBlock-G129-Dex3-Joint` - 堆叠彩色木块（三指灵巧手）
- `Isaac-Stack-RgyBlock-G129-Inspire-Joint` - 堆叠彩色木块（Inspire 手）

**Wholebody 任务（可移动）：**
- `Isaac-Move-Cylinder-G129-Dex1-Wholebody` - 移动并抓取圆柱体（二指夹爪）
- `Isaac-Move-Cylinder-G129-Dex3-Wholebody` - 移动并抓取圆柱体（三指灵巧手）
- `Isaac-Move-Cylinder-G129-Inspire-Wholebody` - 移动并抓取圆柱体（Inspire 手）

#### H1-2 机器人任务

- `Isaac-PickPlace-Cylinder-H12-27dof-Inspire-Joint` - 抓取圆柱体
- `Isaac-PickPlace-RedBlock-H12-27dof-Inspire-Joint` - 抓取红色木块
- `Isaac-Stack-RgyBlock-H12-27dof-Inspire-Joint` - 堆叠彩色木块

---

## 🛠️ 快速切换脚本

### 方法 1: 使用 kill_sim.sh + 手动启动

```bash
# 1. 终止当前任务
bash kill_sim.sh

# 2. 等待几秒确保进程完全退出
sleep 3

# 3. 启动新任务
conda activate unitree_sim_env
source setup_env_vars.sh

python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task <新任务名称> \
    --enable_dex1_dds \
    --robot_type g129 \
    --render_interval 10
```

### 方法 2: 使用 run_demo_fast.sh（推荐）

`run_demo_fast.sh` 脚本会自动清理旧进程并启动新任务：

```bash
cd ~/桌面/playground/unitree_sim_isaaclab
conda activate unitree_sim_env
bash run_demo_fast.sh
```

---

## ⚠️ 注意事项

### 1. 确保进程完全退出

在启动新任务前，确保旧进程已完全退出：

```bash
# 检查是否还有残留进程
pgrep -f "sim_main.py"
pgrep -f "kit.*isaaclab"

# 如果还有，使用 kill_sim.sh 或手动终止
bash kill_sim.sh
```

### 2. GPU 显存清理

如果遇到 GPU 显存不足的问题，确保旧进程已完全退出：

```bash
# 检查 GPU 显存
nvidia-smi

# 如果还有残留，强制终止
pkill -9 -f "sim_main.py|kit.*isaaclab"
```

### 3. 端口占用

如果遇到端口占用问题（DDS 相关），确保所有相关进程已退出：

```bash
# 检查端口占用
netstat -tulpn | grep -E "7400|7401|7402"

# 终止相关进程
bash kill_sim.sh
```

---

## 🔄 任务切换示例

### 示例 1: 从 Joint 任务切换到 Wholebody 任务

```bash
# 1. 终止当前任务
bash kill_sim.sh

# 2. 启动 Wholebody 任务
conda activate unitree_sim_env
source setup_env_vars.sh

python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-Move-Cylinder-G129-Dex1-Wholebody \
    --enable_dex1_dds \
    --robot_type g129 \
    --render_interval 10

# 3. 在另一个终端启动键盘控制
python send_commands_keyboard.py
```

### 示例 2: 切换不同的夹爪类型

```bash
# 从 Dex1 切换到 Dex3
bash kill_sim.sh

conda activate unitree_sim_env
source setup_env_vars.sh

python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex3-Joint \
    --enable_dex3_dds \  # 注意：从 --enable_dex1_dds 改为 --enable_dex3_dds
    --robot_type g129 \
    --render_interval 10
```

---

## 📝 总结

1. **每次切换任务都需要重新启动 Isaac Sim**
2. **使用 `kill_sim.sh` 脚本可以安全地终止所有相关进程**
3. **确保进程完全退出后再启动新任务**
4. **不同的任务可能需要不同的参数（如 `--enable_dex1_dds` vs `--enable_dex3_dds`）**

---

## 🚀 快速参考

```bash
# 终止所有相关进程
bash kill_sim.sh

# 启动新任务（示例）
python sim_main.py \
    --device cuda:0 \
    --enable_cameras \
    --task <任务名称> \
    --enable_dex1_dds \
    --robot_type g129 \
    --render_interval 10
```

