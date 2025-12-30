# 快速开始指南 - RTX 5070 Ti

## 🚀 三步快速安装

### 第一步：安装 NVIDIA 驱动（如果未安装）

```bash
# 检查驱动
nvidia-smi

# 如果未安装，执行：
sudo apt update
sudo apt install -y nvidia-driver-550
sudo reboot
```

### 第二步：运行安装脚本

```bash
cd /home/bz/桌面/playground/unitree_sim_isaaclab

# 先检查系统环境
bash check_system.sh

# 运行自动安装脚本
bash setup_environment.sh
```

### 第三步：验证安装

```bash
# 激活环境
conda activate unitree_sim_env

# 测试运行
python sim_main.py \
    --device cpu \
    --enable_cameras \
    --task Isaac-PickPlace-Cylinder-G129-Dex1-Joint \
    --enable_dex1_dds \
    --robot_type g129 \
    --headless
```

## 📝 详细说明

- **完整安装指南**: 查看 [INSTALL_GUIDE_zh.md](INSTALL_GUIDE_zh.md)
- **项目文档**: 查看 [README_zh-CN.md](README_zh-CN.md)

## ⚠️ 重要提示

1. **RTX 5070 Ti 必须使用 Isaac Sim 5.0.0**（脚本已自动配置）
2. 首次运行 `isaacsim` 需要接受 EULA（输入 `Yes`）
3. 安装过程可能需要 1-2 小时，请耐心等待
4. 确保至少有 50GB 可用磁盘空间

## 🆘 遇到问题？

1. 查看 [INSTALL_GUIDE_zh.md](INSTALL_GUIDE_zh.md) 中的"常见问题"部分
2. 检查系统环境: `bash check_system.sh`
3. 查看项目 GitHub Issues

