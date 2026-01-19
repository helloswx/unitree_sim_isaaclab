# 📦 Assets 文件夹内容说明

## 📊 概览

`assets` 文件夹包含仿真所需的所有资源文件，总大小约 **1.8GB**：

```
assets/
├── model/          (4.9MB)   - 策略模型文件
├── robots/         (544MB)   - 机器人模型
└── objects/        (1.2GB)   - 场景对象和材料
```

---

## 🤖 robots/ - 机器人模型

**大小：** 约 544MB  
**用途：** 包含 G1 和 H1-2 机器人的 3D 模型和配置

### G1 机器人模型

#### 1. Wholebody 配置（可移动）
- **`g1-29dof_wholebody_dex1/`** - G1 + 二指夹爪（Wholebody）
- **`g1-29dof_wholebody_dex3/`** - G1 + 三指灵巧手（Wholebody）
- **`g1-29dof_wholebody_inspire/`** - G1 + Inspire 手（Wholebody）

**文件结构：**
```
g1-29dof_wholebody_dex1/
├── config.yaml                    # 配置文件
├── g1_29dof_with_dex1_rev_1_0.usd  # 主模型文件
└── configuration/
    ├── g1_29dof_with_dex1_rev_1_0_base.usd      # 基础模型
    ├── g1_29dof_with_dex1_rev_1_0_physics.usd   # 物理属性
    └── g1_29dof_with_dex1_rev_1_0_sensor.usd    # 传感器配置
```

#### 2. Base Fix 配置（固定位置）
- **`g1-29dof-dex1-base-fix-usd/`** - G1 + 二指夹爪（固定位置）
- **`g1-29dof-dex3-base-fix-usd/`** - G1 + 三指灵巧手（固定位置）
- **`g1-29dof-inspire-base-fix-usd/`** - G1 + Inspire 手（固定位置）

**用途：** Joint 任务使用这些配置（机器人固定位置）

### H1-2 机器人模型

- **`h1_2-26dof-inspire-base-fix-usd/`** - H1-2 + Inspire 手

**文件结构：**
```
h1_2-26dof-inspire-base-fix-usd/
├── config.yaml
├── h1_2_26dof_with_inspire_rev_1_0.usd
└── configuration/
    ├── h1_2.urdf_base.usd
    ├── h1_2.urdf_physics.usd
    ├── h1_2.urdf_robot.usd
    └── h1_2.urdf_sensor.usd
```

### 文件格式说明

- **`.usd` / `.usda`**: Universal Scene Description 格式，Isaac Sim 使用的场景描述格式
- **`config.yaml`**: 机器人配置文件，包含关节限制、默认位置等信息
- **`*_base.usd`**: 基础几何模型
- **`*_physics.usd`**: 物理属性（质量、惯性、碰撞等）
- **`*_sensor.usd`**: 传感器配置（相机、IMU 等）

---

## 🎯 model/ - 策略模型

**大小：** 约 4.9MB  
**用途：** 训练好的强化学习策略模型

### 文件列表

- **`policy.onnx`** - 默认策略模型
- **`policy1.onnx`** - 备用策略模型

### 使用方法

在运行任务时指定模型路径：

```bash
python sim_main.py \
    --device cuda:0 \
    --task Isaac-PickPlace-RedBlock-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --model_path assets/model/policy.onnx \
    --render_interval 10
```

**注意：** 
- 模型文件是 `.onnx` 格式（Open Neural Network Exchange）
- 用于推理，不需要训练代码
- 如果没有模型，机器人不会自动执行任务

---

## 🏗️ objects/ - 场景对象

**大小：** 约 1.2GB  
**用途：** 场景中的物体、环境、材料等

### 主要对象

#### 1. 仓库场景
- **`small_warehouse/`** - 小型仓库场景
  - `small_warehouse_digital_twin.usd` - 主场景文件
  - `SubUSDs/materials/` - 材质文件（`.mdl`）
  - `SubUSDs/textures/` - 纹理文件（`.png`, `.jpg`）

- **`small_warehouse_digital_twin/`** - 另一个仓库场景版本

**用途：** Wholebody 任务使用这些场景作为环境

#### 2. 桌子
- **`PackingTable/`** - 包装桌模型
- **`PackingTable_1/`** - 包装桌变体 1
- **`PackingTable_2/`** - 包装桌变体 2
- **`table_with_yellowbox.usd`** - 带黄色箱子的桌子

**用途：** Joint 任务中放置物体的桌子

#### 3. 抽屉
- **`drawers/`**
  - `cabinet_collider.usd` - 柜子碰撞体
  - `drawer.usd` - 抽屉模型

**用途：** 抽屉任务中使用

### 材质和纹理

**位置：** `objects/*/SubUSDs/materials/` 和 `objects/*/SubUSDs/textures/`

**材质文件（`.mdl`）：**
- `Aluminum_Anodized_Black.mdl` - 黑色阳极氧化铝
- `Concrete_Polished.mdl` - 抛光混凝土
- `Plastic.mdl` - 塑料
- `Paint_Gloss.mdl` - 光泽漆
- 等等...

**纹理文件（`.png`, `.jpg`）：**
- 各种纹理贴图，用于材质渲染

---

## 📋 文件用途总结

| 文件夹 | 大小 | 用途 | 必需性 |
|--------|------|------|--------|
| **robots/** | 544MB | 机器人 3D 模型 | ✅ 必需 |
| **objects/** | 1.2GB | 场景对象和环境 | ✅ 必需 |
| **model/** | 4.9MB | 策略模型（可选） | ⚠️ 可选 |

---

## 🔍 如何查看资产文件

### 方法 1: 使用 Isaac Sim 查看

1. 打开 Isaac Sim
2. 菜单：`File` → `Open`
3. 选择 `assets/robots/` 或 `assets/objects/` 中的 `.usd` 文件
4. 可以查看模型、材质、纹理等

### 方法 2: 使用命令行

```bash
# 查看机器人模型
ls -lh assets/robots/*/

# 查看场景对象
ls -lh assets/objects/

# 查看策略模型
ls -lh assets/model/
```

---

## 📥 如何下载资产文件

如果 `assets` 文件夹不存在或内容不完整，运行：

```bash
cd ~/桌面/playground/unitree_sim_isaaclab
bash fetch_assets.sh
```

这个脚本会：
1. 从 Hugging Face 下载 `assets.zip`
2. 解压到 `assets/` 文件夹
3. 清理临时文件

**注意：** 下载可能需要一些时间（约 1.8GB）

---

## ⚠️ 重要提示

1. **不要删除 assets 文件夹**：仿真需要这些文件才能运行
2. **assets 文件夹很大**：确保有足够的磁盘空间（至少 2GB）
3. **Git LFS**：如果使用 Git，这些大文件通过 Git LFS 管理
4. **策略模型可选**：没有模型也可以运行仿真，但机器人不会自动执行任务

---

## 🔗 相关文件

- **`fetch_assets.sh`** - 下载资产文件的脚本
- **`robots/unitree.py`** - 机器人配置加载代码
- **`tasks/common_scene/`** - 场景配置，引用 assets 中的文件

---

## 📝 总结

`assets` 文件夹包含：
- **robots/**: 机器人模型（G1, H1-2，不同手部配置）
- **objects/**: 场景对象（仓库、桌子、材质、纹理）
- **model/**: 策略模型（用于自动执行任务）

这些文件是仿真运行的基础，确保它们完整且路径正确。

