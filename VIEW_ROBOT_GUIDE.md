# 👁️ 查看机器人指南

## 问题：画面里没有机器人

从日志可以看到环境已经成功创建，机器人已经加载，但可能视角不对。

## 🔍 解决方案

### 方法 1: 在 Isaac Sim 界面中切换视角（推荐）

**步骤：**

1. **点击 Isaac Sim 窗口**（确保窗口已激活）
   - 日志提示：`***  Please left-click on the Sim window to activate rendering. ***`
   - 先点击窗口激活渲染

2. **查看场景树（左侧面板）**
   - 找到 `World` → `envs` → `env_0` → `Robot`
   - 点击 `Robot` 可以选中机器人

3. **切换到机器人视角**
   - 在右侧面板找到 **"Viewer Settings"** 或 **"Camera"** 部分
   - 或者使用快捷键：
     - `F` - 聚焦到选中的对象
     - `Alt + F` - 将相机移动到选中对象

4. **使用 PerspectiveCamera**
   - 在场景树中找到 `/World/PerspectiveCamera`
   - 双击或右键选择 "Set as Active Camera"
   - 或者使用菜单：`Window` → `Camera` → `PerspectiveCamera`

### 方法 2: 使用相机控制

**在 Isaac Sim 界面中：**

1. **鼠标控制：**
   - **左键拖拽**：旋转视角
   - **中键拖拽**：平移视角
   - **滚轮**：缩放
   - **右键拖拽**：平移

2. **键盘快捷键：**
   - `F` - 聚焦到选中对象
   - `Alt + F` - 将相机移动到选中对象
   - `G` - 切换网格显示
   - `H` - 切换帮助信息

### 方法 3: 检查机器人是否真的存在

**在场景树中查找：**

1. 展开左侧场景树：
   ```
   World
   └── envs
       └── env_0
           ├── Robot  ← 机器人应该在这里
           ├── Room
           ├── PackingTable_1
           └── PackingTable_2
   ```

2. 如果找到 `Robot`：
   - 右键点击 `Robot`
   - 选择 "Focus on Selection" 或 "Frame Selection"
   - 机器人应该会出现在视野中

3. 如果找不到 `Robot`：
   - 可能是场景加载问题
   - 尝试重新启动任务

### 方法 4: 使用世界相机

**在右侧面板的 "Viewer Settings" 中：**

1. 找到 **"Camera Eye"** 和 **"Camera Target"** 设置
2. 调整相机位置：
   - **Camera Eye**: `X: 2.0, Y: 2.0, Z: 1.5`（相机位置）
   - **Camera Target**: `X: 0.0, Y: 0.0, Z: 0.5`（看向的位置）

3. 或者使用预设视角：
   - 在菜单栏：`Window` → `Layouts` → 选择不同的布局
   - 或者使用 `View` → `Frame All` 显示所有对象

### 方法 5: 检查机器人位置

**机器人可能不在视野范围内：**

1. **Wholebody 任务的机器人初始位置**可能在：
   - 场景的中心位置
   - 或者在地面的某个特定位置

2. **使用 "Frame All" 功能**：
   - 菜单：`View` → `Frame All`
   - 或者快捷键（如果有）
   - 这会调整视角显示所有对象

## 🎯 快速操作步骤

### 最简单的方法：

1. **点击 Isaac Sim 窗口**（激活渲染）

2. **在左侧场景树中找到机器人：**
   ```
   World → envs → env_0 → Robot
   ```

3. **选中 Robot，然后按 `F` 键**（聚焦到机器人）

4. **如果还是看不到，尝试：**
   - 使用鼠标中键拖拽平移视角
   - 使用滚轮缩放
   - 使用左键拖拽旋转视角

## 🔧 如果仍然看不到机器人

### 检查 1: 确认机器人已加载

查看终端输出，应该看到：
```
✅ Found robot object: <class 'isaaclab.assets.articulation.articulation.Articulation'>
```

如果看到这个，说明机器人已经加载。

### 检查 2: 检查渲染是否激活

终端提示：
```
***  Please left-click on the Sim window to activate rendering. ***
```

确保已经点击了窗口。

### 检查 3: 重新启动任务

如果以上方法都不行，尝试：

1. **终止当前任务：**
   ```bash
   bash kill_sim.sh
   ```

2. **重新启动：**
   ```bash
   conda activate unitree_sim_env
   source setup_env_vars.sh
   
   python sim_main.py \
       --device cuda:0 \
       --enable_cameras \
       --task Isaac-Move-Cylinder-G129-Dex1-Wholebody \
       --enable_dex1_dds \
       --robot_type g129 \
       --render_interval 10
   ```

3. **等待完全加载后，点击窗口激活渲染**

## 📝 常见问题

### Q1: 窗口是黑色的

**原因：** 渲染未激活

**解决：** 点击窗口，等待几秒让渲染启动

### Q2: 能看到场景但看不到机器人

**原因：** 视角不对或机器人位置不在视野内

**解决：** 
- 使用 `F` 键聚焦到机器人
- 或使用 "Frame All" 显示所有对象

### Q3: 场景树中没有 Robot

**原因：** 场景加载失败

**解决：** 检查终端错误信息，重新启动任务

## 🎬 预期效果

成功看到机器人后，你应该能看到：
- 一个白色和黑色的人形机器人（G1）
- 机器人站在场景中
- 周围有桌子、箱子等物体
- 可以控制机器人移动（如果运行了键盘控制脚本）

---

## 💡 提示

- **Wholebody 任务**的机器人初始位置可能在场景中心
- 使用 `F` 键是最快的聚焦方法
- 如果场景很大，使用 "Frame All" 可以显示所有内容
- 确保窗口已激活（点击窗口）

