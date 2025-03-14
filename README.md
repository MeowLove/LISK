# LISK (Linux Init Setup Kit)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/MeowLove/LISK.svg)](https://github.com/MeowLove/LISK/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/MeowLove/LISK.svg)](https://github.com/MeowLove/LISK/network)
[![GitHub issues](https://img.shields.io/github/issues/MeowLove/LISK.svg)](https://github.com/MeowLove/LISK/issues)

[**简体中文**](README_zh-CN.md) | [English](./README.md)

> **Note:** LISK is currently under active development.  While core functionality is being built, expect changes and potential instability.  We appreciate early testers and contributors!  For production environments, please carefully review and test scripts before use.

Quickly initialize and configure your Linux system with LISK: a simple, secure, and extensible setup toolkit. Automate essential tasks and customize your setup with ease.

## ✨ Features

*   **Automated:** Automates common Linux system initialization and configuration tasks, saving you time and effort.
*   **Customizable:** Allows you to choose which tasks to perform and configure parameters to match your specific needs.
*   **Modular:** Uses a modular design with independent scripts for each function, making it easy to maintain and extend.
*   **Compatible:** Supports a wide range of popular Linux distributions.
*   **User-Friendly:** Provides a simple, menu-driven interface for easy operation.
*   **Reliable:** Includes error handling, progress indication, logging, and confirmation mechanisms.
*   **Secure:** Follows security best practices and avoids introducing security risks.
*   **Extensible:** Supports user-defined scripts (plugins) and API integration. (Planned)
*   **Multi-tasking:** Supports running multiple tasks concurrently. (Planned)

## 🚀 Getting Started

1.  **Download:**

    ```bash
    curl -sSL https://raw.githubusercontent.com/MeowLove/LISK/main/LISK.sh -o LISK.sh
    ```

2.  **Make it executable:**

    ```bash
    chmod +x LISK.sh
    ```

3.  **Run as root:**

    ```bash
    sudo ./LISK.sh
    ```

## 💻 Supported Distributions

*   RHEL Series (CentOS, RHEL, Rocky Linux, AlmaLinux, Oracle Linux, Amazon Linux 2023, openEuler, Anolis OS, CentOS Stream, EuroLinux, TencentOS Server)
*   Fedora
*   Debian Series (Debian, Ubuntu, Deepin, Kali Linux)
*   openSUSE/SLES
*   Alpine Linux
*   Arch Linux
*   统信 UOS (UnionTech OS)

**Not Supported:**

*   Gentoo
*   FreeBSD
*   SUSE Linux Enterprise Micro

## 🛠️ Use Cases

*   **Server initialization:** Quickly set up new servers with essential configurations.
*   **Development environment setup:** Configure development environments with necessary tools and settings.
*   **System recovery:** Restore system configurations from backups. (Planned)
*   **Batch deployment:** Deploy consistent configurations across multiple systems.
*   **Custom system setup:** Create tailored system setups for specific needs.

## 🤝 Contributing

Contributions are welcome!  Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.  We encourage you to submit issues, feature requests, and pull requests to our [development repository](https://github.com/MeowLove/Linux-Init-Setup-Kit).

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💬 Community

*   GitHub Issues: [https://github.com/MeowLove/LISK/issues](https://github.com/MeowLove/LISK/issues)
*   Development Repository: [https://github.com/MeowLove/Linux-Init-Setup-Kit](https://github.com/MeowLove/Linux-Init-Setup-Kit)

## 🗺️ Roadmap

*   [x] Basic framework implementation.
*   [ ] User script (plugin) support.
*   [ ] System backup and restore functionality.
*   [ ] Web-based GUI. (Optional)
*   [ ] More scripts and enhanced functionality for existing modules.