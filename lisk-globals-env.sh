#!/bin/bash

# lisk-globals-env.sh: LISK 全局环境变量和自动检测函数

# 全局变量 (根据需求文档 v1.17)
LISK_FIRST_RUN=1  # 是否首次运行 (0 或 1)。初始值为1。
LISK_BASE_DIR=""  # 工具箱基本目录 (由 _lisk_update_base_dir() 函数更新)。
LISK_DOWNLOAD_BASE_URL="https://www.cxthhhhh.com/LISK/"  # 下载源 URL (稳定版)。
LISK_DOWNLOAD_BASE_URL_RECOMMEND="https://www.cxthhhhh.com/LISK/" # 推荐下载源 URL (稳定版)。
LISK_DOWNLOAD_BASE_URL_BETA="https://raw.githubusercontent.com/MeowLove/Linux-Init-Setup-Kit/main" # 测试版下载源 URL。
LISK_DISTRO=""   # 发行版名称。
LISK_DISTRO_VERSION=""  # 发行版版本号。
LISK_DISTRO_FAMILY=""   # 发行版父级分类 (如 "RHEL", "Debian", "SUSE", "Arch", "Alpine", "Unknown")。
LISK_KERNEL_VERSION=""  # 内核版本。
LISK_ARCHITECTURE=""  # 系统架构 (如x86_64, arm64)。
LISK_VIRTUALIZATION=""  # 虚拟化类型 (如 "kvm", "xen", "vmware", "hyperv", "lxd", "docker", "wsl", "none", "unknown")。
LISK_TUN_TAP_ENABLED=""  # TUN/TAP 是否启用 ("true" 或 "false")。
LISK_CLOUD_INIT_ENABLED=""  #  Cloud-init 是否启用 ("true" 或 "false")。
LISK_QEMU_GA_ENABLED=""  # QEMU Guest Agent 是否启用 ("true" 或 "false")。
# LISK_AGENT_TYPE=""        # 安装的agent类型, 可能有多个, 暂时删除
LISK_IS_CONTAINER=""    # 是否在容器中运行。
LISK_CPU_MODEL=""        # CPU型号。
LISK_CPU_CORES=""        # CPU核心数。
LISK_MEMORY_TOTAL=""    # 总内存大小 (MB)。
LISK_DISK_TOTAL=""       # 总磁盘空间 (GB)。
LISK_DEFAULT_DATA_DIR="/data" # 默认数据目录。
LISK_DEFAULT_LOG_DIR="/var/log"  # 默认日志目录。
LISK_DEFAULT_USERNAME="root"  # 默认用户名。
LISK_DEFAULT_PASSWORD="cxthhhhh.com"  # 默认密码。  (强烈建议不要在脚本中存储明文密码，这里只是示例)
LISK_DEFAULT_EDITOR="vi"   # 默认编辑器。
LISK_DEFAULT_DOWNLOADER="curl"  # 默认下载器
LISK_DEFAULT_LANG="EN"             # 默认语言。
LISK_EXTERNAL_IP=""      # 外网 IP。
LISK_COUNTRY_CODE=""     # 国家/地区代码。
LISK_LOG_LEVEL="INFO"    # 日志级别 (INFO, WARN, ERROR, DEBUG)。
LISK_USER_CONFIG_FILE="$LISK_BASE_DIR/lisk-user-config.json"  # 用户配置文件路径。
LISK_TEMP_DIR="/tmp/lisk"       # 临时文件目录。
LISK_SCRIPT_TIMEOUT=300   # 脚本执行超时时间 (秒)。
LISK_DOWNLOAD_TIMEOUT=30 # 下载超时时间 (秒)。
LISK_MAX_RETRIES=3       # 最大重试次数 (用于下载等操作)。
LISK_YES_TO_ALL="false"   # 自动回答yes, **谨慎使用, 存在风险**

# _lisk_update_base_dir(): 更新 LISK_BASE_DIR 变量。
_lisk_update_base_dir() {
    # 使用 readlink -f 获取当前脚本的绝对路径
    # 确保在符号链接的情况下也能正确获取路径
    local script_path="$(readlink -f "${BASH_SOURCE[0]}")"
    # 获取脚本所在的目录
    LISK_BASE_DIR="$(dirname "$script_path")"

    # 更新 LISK_USER_CONFIG_FILE 变量
    LISK_USER_CONFIG_FILE="$LISK_BASE_DIR/lisk-user-config.json"
}

# _lisk_detect_distro(): 自动检测 Linux 发行版。
_lisk_detect_distro() {
    local id=""
    local version_id=""
    #LISK_DISTRO_FAMILY="" # 初始化父级发行版, 全局变量已定义

    # 优先使用 /etc/os-release
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1090
        source /etc/os-release
        id="$ID"
        version_id="$VERSION_ID"
    fi

    # 根据 ID 进行分类
    case "$id" in
        debian|ubuntu|kali)
            LISK_DISTRO="$id"         # 保留原始发行版名称
            LISK_DISTRO_VERSION="$version_id"
            LISK_DISTRO_FAMILY="Debian"  # 设置父级发行版
            ;;
        centos|rhel|fedora|rocky|almalinux|ol)
            LISK_DISTRO="$id"         # 保留原始发行版名称
            LISK_DISTRO_VERSION="$version_id"
            LISK_DISTRO_FAMILY="RHEL"    # 设置父级发行版
            ;;
        opensuse*|sles*)
            LISK_DISTRO="$id"         # 保留原始发行版名称
            LISK_DISTRO_VERSION="$version_id"
            LISK_DISTRO_FAMILY="SUSE"   # 设置父级发行版
            ;;
        alpine)
            LISK_DISTRO="Alpine"
            LISK_DISTRO_VERSION=$(cat /etc/alpine-release)
            LISK_DISTRO_FAMILY="Alpine" # Alpine 自成一类
            ;;
        arch)
            LISK_DISTRO="Arch"
            LISK_DISTRO_VERSION=""
            LISK_DISTRO_FAMILY="Arch"   # Arch 自成一类
            ;;
        deepin)  # Deepin
            LISK_DISTRO="Deepin"
            LISK_DISTRO_VERSION="$version_id"
            LISK_DISTRO_FAMILY="Debian"  # Deepin 基于 Debian
            ;;
        UOS)  # 统信 UOS
            LISK_DISTRO="UOS"
            LISK_DISTRO_VERSION="$version_id" # 使用 os-release 中的版本
            if command -v dnf &> /dev/null; then
                LISK_DISTRO_FAMILY="RHEL"
            elif command -v apt &> /dev/null; then
                LISK_DISTRO_FAMILY="Debian"
            else
                LISK_DISTRO_FAMILY="Unknown"
            fi
            ;;
        *)  # 其他发行版
            if [ -n "$id" ]; then # 如果 /etc/os-release 已读取
                LISK_DISTRO_FAMILY="Unknown"  # 无法识别的父级分类
                 case "$ID_LIKE" in # 根据ID_LIKE再次判断
                    *debian*)
                        LISK_DISTRO_FAMILY="Debian"
                        ;;
                    *suse*)
                        LISK_DISTRO_FAMILY="SUSE"
                        ;;
                    *rhel*|*fedora*)
                        LISK_DISTRO_FAMILY="RHEL"
                        ;;
                    *)
                        ;;
                esac
            else # 如果 /etc/os-release 不存在或读取失败
              LISK_DISTRO="Unknown"
              LISK_DISTRO_VERSION="Unknown"
              LISK_DISTRO_FAMILY="Unknown"
            fi
            ;;
    esac
}

# _lisk_detect_kernel(): 自动检测 kernel 版本
_lisk_detect_kernel() {
  LISK_KERNEL_VERSION=$(uname -r)
}

# _lisk_detect_architecture(): 检测系统架构。
_lisk_detect_architecture() {
  LISK_ARCHITECTURE=$(uname -m)
}

# _lisk_detect_virtualization(): 检测虚拟化类型。
_lisk_detect_virtualization() {
  if command -v systemd-detect-virt &> /dev/null; then
    LISK_VIRTUALIZATION=$(systemd-detect-virt)
  elif command -v virt-what &> /dev/null; then
    LISK_VIRTUALIZATION=$(virt-what)
  else
    LISK_VIRTUALIZATION="unknown"
  fi
}

# _lisk_detect_tun_tap(): 检测 TUN/TAP 是否启用。
_lisk_detect_tun_tap() {
  if [ -d /dev/net ] && [ -c /dev/net/tun ]; then
    LISK_TUN_TAP_ENABLED="true"
  else
    LISK_TUN_TAP_ENABLED="false"
  fi
}

# _lisk_detect_cloud_init(): 检测 Cloud-init 是否启用。
_lisk_detect_cloud_init() {
  if [ -d /run/cloud-init ] || [ -f /etc/cloud/cloud.cfg ]; then
    LISK_CLOUD_INIT_ENABLED="true"
  else
    LISK_CLOUD_INIT_ENABLED="false"
  fi
}

# _lisk_detect_qemu_ga(): 检测 QEMU Guest Agent 是否启用。
_lisk_detect_qemu_ga() {
  if pgrep -x "qemu-ga" &> /dev/null; then
    LISK_QEMU_GA_ENABLED="true"
  else
    LISK_QEMU_GA_ENABLED="false"
  fi
}

# _lisk_detect_container(): 自动检测是否在容器中运行。
_lisk_detect_container() {
   if [ -f /.dockerenv ] || [ -d /.docker ];then
    LISK_IS_CONTAINER="true"
   elif grep -q container=lxc /proc/1/environ || grep -q 'container=lxc-libvirt' /proc/1/environ; then
    LISK_IS_CONTAINER="true"
   elif systemd-detect-virt --container &> /dev/null; then
    LISK_IS_CONTAINER="true"
   else
    LISK_IS_CONTAINER="false"
   fi
}

# _lisk_detect_cpu_info(): 检测CPU型号和核心数。
_lisk_detect_cpu_info() {
  if [ -f /proc/cpuinfo ]; then
    LISK_CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d ':' -f 2 | sed 's/^[ \t]*//')
    LISK_CPU_CORES=$(grep -c "processor" /proc/cpuinfo)
  else
     LISK_CPU_MODEL="Unknown"
     LISK_CPU_CORES="Unknown"
  fi
}

# _lisk_detect_memory_info(): 检测总内存大小。
_lisk_detect_memory_info() {
  if [ -f /proc/meminfo ]; then
    LISK_MEMORY_TOTAL=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
    # 将 kB 转换为 MB
    LISK_MEMORY_TOTAL=$((LISK_MEMORY_TOTAL / 1024))
  else
    LISK_MEMORY_TOTAL="Unknown"
  fi
}

# _lisk_detect_disk_info(): 检测总磁盘空间。
_lisk_detect_disk_info() {
    # 使用 df 命令，并排除 tmpfs, devtmpfs 和 overlay 文件系统
    # 统计以 GB 为单位的总磁盘空间
    # 2>/dev/null 确保在没有/proc文件时，不报错
    LISK_DISK_TOTAL=$(df -H --total --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=overlay 2>/dev/null | tail -n 1 | awk '{print $2}' | sed 's/G//')

  if [ -z "$LISK_DISK_TOTAL" ]; then
     LISK_DISK_TOTAL="Unknown"
  fi
}

# _lisk_detect_external_ip(): 自动检测外网 IP。
_lisk_detect_external_ip() {
    LISK_EXTERNAL_IP=$(curl -s -m "$LISK_DOWNLOAD_TIMEOUT" https://ipinfo.io/ip 2>/dev/null)
    if [[ -z "$LISK_EXTERNAL_IP" ]]; then
      # 备用方案：ifconfig.io
      LISK_EXTERNAL_IP=$(curl -s -m "$LISK_DOWNLOAD_TIMEOUT" https://ifconfig.io/ip 2>/dev/null)
    fi
    #IP格式校验
    if [ -z "$LISK_EXTERNAL_IP" ] || !  grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" <<< "$LISK_EXTERNAL_IP";then
        LISK_EXTERNAL_IP="Unknown"
    fi
}

# _lisk_detect_country_code(): 自动检测国家/地区代码。
_lisk_detect_country_code() {
  if [ "$LISK_EXTERNAL_IP" != "Unknown" ]; then
    LISK_COUNTRY_CODE=$(curl -s -m "$LISK_DOWNLOAD_TIMEOUT" "https://ipinfo.io/country" 2>/dev/null)
    if [[ -z "$LISK_COUNTRY_CODE" ]]; then
      # 备用方案：ifconfig.io
      LISK_COUNTRY_CODE=$(curl -s -m "$LISK_DOWNLOAD_TIMEOUT" "https://ifconfig.io/country_code" 2>/dev/null)
    fi
  fi

  if [ -z "$LISK_COUNTRY_CODE" ]; then
    LISK_COUNTRY_CODE="Unknown"
  fi
}

# _lisk_check_internet_connection(): 检查网络连接, 可以用于后续其他脚本下载, 网络访问, **DNS解析**中。
_lisk_check_internet_connection() {
    # 使用多个 DNS 服务器进行检测，提高可靠性
    timeout "$LISK_SCRIPT_TIMEOUT" bash -c "</dev/tcp/1.1.1.1/53" 2>/dev/null && return 0
    timeout "$LISK_SCRIPT_TIMEOUT" bash -c "</dev/tcp/8.8.8.8/53" 2>/dev/null && return 0
    timeout "$LISK_SCRIPT_TIMEOUT" bash -c "</dev/tcp/223.5.5.5/53" 2>/dev/null && return 0
    timeout "$LISK_SCRIPT_TIMEOUT" bash -c "</dev/tcp/4.2.2.1/53" 2>/dev/null && return 0
    return 1 # 如果所有检测都失败，返回 1
}

# 参数处理：-a (更新所有推荐值)
if [ "$1" = "-a" ]; then
  _lisk_update_base_dir
  _lisk_detect_distro
  _lisk_detect_kernel
  _lisk_detect_architecture
  _lisk_detect_virtualization
  _lisk_detect_tun_tap
  _lisk_detect_cloud_init
  _lisk_detect_qemu_ga
  _lisk_detect_container
  _lisk_detect_cpu_info
  _lisk_detect_memory_info
  _lisk_detect_disk_info
  _lisk_detect_external_ip
  _lisk_detect_country_code
  _lisk_check_internet_connection

  # 使用 sed 命令更新变量值
  # 注意：这里需要对特殊字符进行转义，如 $、/、& 等
  # shellcheck disable=SC2089
  sed -i "s|LISK_BASE_DIR=.*|LISK_BASE_DIR=\"$LISK_BASE_DIR\"|" "$0"
  sed -i "s|LISK_DISTRO=.*|LISK_DISTRO=\"$LISK_DISTRO\"|" "$0"
  sed -i "s|LISK_DISTRO_VERSION=.*|LISK_DISTRO_VERSION=\"$LISK_DISTRO_VERSION\"|" "$0"
  sed -i "s|LISK_DISTRO_FAMILY=.*|LISK_DISTRO_FAMILY=\"$LISK_DISTRO_FAMILY\"|" "$0"
  sed -i "s|LISK_KERNEL_VERSION=.*|LISK_KERNEL_VERSION=\"$LISK_KERNEL_VERSION\"|" "$0"
  sed -i "s|LISK_ARCHITECTURE=.*|LISK_ARCHITECTURE=\"$LISK_ARCHITECTURE\"|" "$0"
  sed -i "s|LISK_VIRTUALIZATION=.*|LISK_VIRTUALIZATION=\"$LISK_VIRTUALIZATION\"|" "$0"
  sed -i "s|LISK_TUN_TAP_ENABLED=.*|LISK_TUN_TAP_ENABLED=\"$LISK_TUN_TAP_ENABLED\"|" "$0"
  sed -i "s|LISK_CLOUD_INIT_ENABLED=.*|LISK_CLOUD_INIT_ENABLED=\"$LISK_CLOUD_INIT_ENABLED\"|" "$0"
  sed -i "s|LISK_QEMU_GA_ENABLED=.*|LISK_QEMU_GA_ENABLED=\"$LISK_QEMU_GA_ENABLED\"|" "$0"
  sed -i "s|LISK_IS_CONTAINER=.*|LISK_IS_CONTAINER=\"$LISK_IS_CONTAINER\"|" "$0"
  sed -i "s|LISK_CPU_MODEL=.*|LISK_CPU_MODEL=\"$LISK_CPU_MODEL\"|" "$0"
  sed -i "s|LISK_CPU_CORES=.*|LISK_CPU_CORES=\"$LISK_CPU_CORES\"|" "$0"
  sed -i "s|LISK_MEMORY_TOTAL=.*|LISK_MEMORY_TOTAL=\"$LISK_MEMORY_TOTAL\"|" "$0"
  sed -i "s|LISK_DISK_TOTAL=.*|LISK_DISK_TOTAL=\"$LISK_DISK_TOTAL\"|" "$0"
  sed -i "s|LISK_EXTERNAL_IP=.*|LISK_EXTERNAL_IP=\"$LISK_EXTERNAL_IP\"|" "$0"
  sed -i "s|LISK_COUNTRY_CODE=.*|LISK_COUNTRY_CODE=\"$LISK_COUNTRY_CODE\"|" "$0"
  exit 0
fi