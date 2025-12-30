# 📦 环境安装说明

本项目提供了完整的自动化安装脚本和详细文档，帮助您快速搭建开发环境。

## 🚀 快速开始

### 三步安装

1. **检查系统环境**
   ```bash
   bash check_system.sh
   ```

2. **接受 Conda TOS**（首次使用需要）
   ```bash
   conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
   conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
   ```

3. **运行自动安装脚本**
   ```bash
   bash setup_environment.sh
   ```

## 📚 文档导航

- **[INSTALLATION_zh.md](INSTALLATION_zh.md)** - 📖 **完整安装指南**（推荐阅读）
  - 详细的安装步骤
  - 常见问题解决方案
  - RTX 50 系列显卡特别说明
  - 验证安装方法

- **[QUICKSTART_zh.md](QUICKSTART_zh.md)** - ⚡ 快速开始指南
  - 三步快速安装流程
  - 关键步骤说明

- **[INSTALL_GUIDE_zh.md](INSTALL_GUIDE_zh.md)** - 🔧 安装指南（备用）
  - 详细的安装步骤
  - 问题排查指南

## 🛠️ 提供的工具

### 安装脚本

- **`setup_environment.sh`** - 自动安装脚本
  - 自动检测和安装所有依赖
  - 支持 RTX 50 系列显卡（Isaac Sim 5.0.0）
  - 自动处理常见问题

- **`check_system.sh`** - 系统环境检查脚本
  - 检查 Ubuntu 版本
  - 检查 NVIDIA 驱动
  - 检查磁盘空间
  - 检查网络连接

- **`after_reboot.sh`** - 重启后验证脚本
  - 验证 NVIDIA 驱动
  - 继续安装流程

## 📋 系统要求

- **操作系统**: Ubuntu 22.04 或更高版本
- **显卡**: NVIDIA RTX 系列
  - RTX 30/40 系列：Isaac Sim 4.5.0 或 5.0.0
  - **RTX 50 系列（包括 RTX 5070 Ti）**：**必须使用 Isaac Sim 5.0.0**
- **内存**: 16GB+（推荐 32GB+）
- **存储**: 至少 50GB 可用空间

## ⚠️ 重要提示

1. **RTX 50 系列显卡**: 必须使用 Isaac Sim 5.0.0 版本
2. **NVIDIA 驱动**: 确保驱动正常工作（`nvidia-smi` 能正常显示）
3. **网络**: 安装过程需要下载大量文件，确保网络稳定
4. **时间**: 完整安装大约需要 1-2 小时

## 🔗 相关链接

- [项目 README](README_zh-CN.md)
- [GitHub 上传指南](GITHUB_UPLOAD.md)
- [上传检查清单](UPLOAD_CHECKLIST.md)

## 💡 获取帮助

如果遇到问题：

1. 查看 [INSTALLATION_zh.md](INSTALLATION_zh.md) 中的"常见问题"部分
2. 运行 `bash check_system.sh` 检查系统环境
3. 查看项目 GitHub Issues
4. 加入 Discord 社区

