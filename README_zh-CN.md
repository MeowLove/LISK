# LISK (Linux 系统初始化设置工具箱)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![GitHub stars](https://img.shields.io/github/stars/MeowLove/LISK.svg)](https://github.com/MeowLove/LISK/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/MeowLove/LISK.svg)](https://github.com/MeowLove/LISK/network)
[![GitHub issues](https://img.shields.io/github/issues/MeowLove/LISK.svg)](https://github.com/MeowLove/LISK/issues)

[**简体中文**](README_zh-CN.md) | [English](./README.md)

> **注意：** LISK 目前正在积极开发中。虽然核心功能正在构建中，但预计会有更改和潜在的不稳定性。我们感谢早期的测试人员和贡献者！对于生产环境，请在使用前仔细审查和测试脚本。

使用 LISK 快速初始化和配置您的 Linux 系统：一个简单、安全且可扩展的设置工具包。轻松自动执行基本任务并自定义您的设置。

## ✨ 功能特性

*   **自动化：** 自动执行常见的 Linux 系统初始化和配置任务，节省您的时间和精力。
*   **可定制：** 允许您选择要执行的任务并配置参数以满足您的特定需求。
*   **模块化：** 使用模块化设计，每个功能都有独立的脚本，易于维护和扩展。
*   **兼容性：** 支持各种流行的 Linux 发行版。
*   **用户友好：** 提供简单的菜单驱动界面，方便操作。
*   **可靠性：** 包括错误处理、进度指示、日志记录和确认机制。
*   **安全性：** 遵循安全最佳实践，避免引入安全风险。
*   **可扩展：** 支持用户定义的脚本（插件）和 API 集成。（计划中）
*   **多任务：** 支持同时运行多个任务。（计划中）

## 🚀 快速开始

1.  **下载：**

    ```bash
    curl -sSL https://raw.githubusercontent.com/MeowLove/LISK/main/LISK.sh -o LISK.sh
    ```

2.  **赋予可执行权限：**

    ```bash
    chmod +x LISK.sh
    ```

3.  **以 root 权限运行：**

    ```bash
    sudo ./LISK.sh
    ```

## 💻 支持的发行版

*   RHEL 系列 (CentOS, RHEL, Rocky Linux, AlmaLinux, Oracle Linux, Amazon Linux 2023, openEuler, Anolis OS, CentOS Stream, EuroLinux, TencentOS Server)
*   Fedora
*   Debian 系列 (Debian, Ubuntu, Deepin, Kali Linux)
*   openSUSE/SLES
*   Alpine Linux
*   Arch Linux
*   统信 UOS (UnionTech OS)

**不支持：**

*   Gentoo
*   FreeBSD
*   SUSE Linux Enterprise Micro

## 🛠️ 使用场景

*   **服务器初始化：** 使用基本配置快速设置新服务器。
*   **开发环境设置：** 使用必要的工具和设置配置开发环境。
*   **系统恢复：** 从备份恢复系统配置。（计划中）
*   **批量部署：** 在多个系统上部署一致的配置。
*   **自定义系统设置：** 为特定需求创建定制的系统设置。

## 🤝 贡献

欢迎贡献！我们鼓励您向我们的[开发仓库](https://github.com/MeowLove/Linux-Init-Setup-Kit) 提交问题、功能请求和拉取请求。更详细的贡献指南将很快发布。（目前，请遵循开发仓库 README 中的通用指南）。

## 📝 许可证

本项目根据 GNU General Public License v3.0 授权 - 有关详细信息，请参阅 [LICENSE](LICENSE) 文件。

## 💬 社区

*   GitHub 问题：[https://github.com/MeowLove/LISK/issues](https://github.com/MeowLove/LISK/issues)
*   开发仓库：[https://github.com/MeowLove/Linux-Init-Setup-Kit](https://github.com/MeowLove/Linux-Init-Setup-Kit)

## 🗺️ 路线图

*   [x] 基础框架搭建完成
*   [ ] 用户自定义脚本(插件)支持
*   [ ] 系统备份和恢复功能
*   [ ] 网页版GUI (可选)
*   [ ] 更多脚本和增强现有模块的功能。