#!/bin/bash

# lisk-globals-env.sh: LISK global environment variables and auto-detection functions

# Global variables
LISK_FIRST_RUN=1
LISK_BASE_DIR=""
LISK_DOWNLOAD_BASE_URL="https://www.cxthhhhh.com/LISK/"
LISK_DOWNLOAD_BASE_URL_RECOMMEND="https://www.cxthhhhh.com/LISK/"
LISK_DOWNLOAD_BASE_URL_BETA="https://raw.githubusercontent.com/MeowLove/Linux-Init-Setup-Kit/main"
LISK_DISTRO=""
LISK_DISTRO_VERSION=""
LISK_DISTRO_FAMILY=""
LISK_KERNEL_VERSION=""
LISK_ARCHITECTURE=""
LISK_VIRTUALIZATION=""
LISK_TUN_TAP_ENABLED=""
LISK_CLOUD_INIT_ENABLED=""
LISK_QEMU_GA_ENABLED=""
# LISK_AGENT_TYPE="" # Temporarily removed
LISK_IS_CONTAINER=""
LISK_CPU_MODEL=""
LISK_CPU_CORES=""
LISK_MEMORY_TOTAL=""
LISK_DISK_TOTAL=""
LISK_DEFAULT_DATA_DIR="/data"
LISK_DEFAULT_LOG_DIR="/var/log"
LISK_DEFAULT_USERNAME="root"
LISK_DEFAULT_PASSWORD="cxthhhhh.com"  # It is strongly recommended not to store plain text passwords in the script; this is just an example.
LISK_DEFAULT_EDITOR="vi"
LISK_DEFAULT_DOWNLOADER="curl"
LISK_DEFAULT_LANG="EN"
LISK_EXTERNAL_IP=""
LISK_COUNTRY_CODE=""
LISK_LOG_LEVEL="INFO"
LISK_USER_CONFIG_FILE="$LISK_BASE_DIR/lisk-user-config.json"
LISK_TEMP_DIR="/tmp/lisk"
LISK_SCRIPT_TIMEOUT=300
LISK_DOWNLOAD_TIMEOUT=30
LISK_MAX_RETRIES=3
LISK_YES_TO_ALL="false"
# End of global variables

# Updates the LISK_BASE_DIR variable.
_lisk_update_base_dir() {
    local script_path="$(readlink -f "${BASH_SOURCE[0]}")"
    LISK_BASE_DIR="$(dirname "$script_path")"
    LISK_USER_CONFIG_FILE="$LISK_BASE_DIR/lisk-user-config.json"
}

# Automatically detects the Linux distribution.
_lisk_detect_distro() {
    local id=""
    local version_id=""

    # Prefer /etc/os-release
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1090
        source /etc/os-release
        id="$ID"
        version_id="$VERSION_ID"
    fi

    # Classify based on ID
    case "$id" in
        debian|ubuntu|kali)
            LISK_DISTRO="$id"
            LISK_DISTRO_VERSION="$version_id"
            LISK_DISTRO_FAMILY="Debian"
            ;;
        centos|rhel|fedora|rocky|almalinux|ol)
            LISK_DISTRO="$id"
            LISK_DISTRO_VERSION="$version_id"
            LISK_DISTRO_FAMILY="RHEL"
            ;;
        opensuse*|sles*)
            LISK_DISTRO="$id"
            LISK_DISTRO_VERSION="$version_id"
            LISK_DISTRO_FAMILY="SUSE"
            ;;
        alpine)
            LISK_DISTRO="Alpine"
            LISK_DISTRO_VERSION=$(cat /etc/alpine-release)
            LISK_DISTRO_FAMILY="Alpine"
            ;;
        arch)
            LISK_DISTRO="Arch"
            LISK_DISTRO_VERSION=""
            LISK_DISTRO_FAMILY="Arch"
            ;;
        deepin)  # Deepin
            LISK_DISTRO="Deepin"
            LISK_DISTRO_VERSION="$version_id"
            LISK_DISTRO_FAMILY="Debian"
            ;;
        UOS)  # 统信 UOS
            LISK_DISTRO="UOS"
            LISK_DISTRO_VERSION="$version_id"
            if command -v dnf &> /dev/null; then
                LISK_DISTRO_FAMILY="RHEL"
            elif command -v apt &> /dev/null; then
                LISK_DISTRO_FAMILY="Debian"
            else
                LISK_DISTRO_FAMILY="Unknown"
            fi
            ;;
        *)  # Other distributions
            if [ -n "$id" ]; then
                LISK_DISTRO_FAMILY="Unknown"
                 case "$ID_LIKE" in
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
            else
              LISK_DISTRO="Unknown"
              LISK_DISTRO_VERSION="Unknown"
              LISK_DISTRO_FAMILY="Unknown"
            fi
            ;;
    esac
}

# Automatically detects the kernel version.
_lisk_detect_kernel() {
  LISK_KERNEL_VERSION=$(uname -r)
}

# Detects the system architecture.
_lisk_detect_architecture() {
  LISK_ARCHITECTURE=$(uname -m)
}

# Detects the virtualization type.
_lisk_detect_virtualization() {
  if command -v systemd-detect-virt &> /dev/null; then
    LISK_VIRTUALIZATION=$(systemd-detect-virt)
  elif command -v virt-what &> /dev/null; then
    LISK_VIRTUALIZATION=$(virt-what)
  else
    LISK_VIRTUALIZATION="unknown"
  fi
}

# Detects whether TUN/TAP is enabled.
_lisk_detect_tun_tap() {
  if [ -d /dev/net ] && [ -c /dev/net/tun ]; then
    LISK_TUN_TAP_ENABLED="true"
  else
    LISK_TUN_TAP_ENABLED="false"
  fi
}

# Detects whether Cloud-init is enabled.
_lisk_detect_cloud_init() {
  if [ -d /run/cloud-init ] || [ -f /etc/cloud/cloud.cfg ]; then
    LISK_CLOUD_INIT_ENABLED="true"
  else
    LISK_CLOUD_INIT_ENABLED="false"
  fi
}

# Detects whether QEMU Guest Agent is enabled.
_lisk_detect_qemu_ga() {
  if pgrep -x "qemu-ga" &> /dev/null; then
    LISK_QEMU_GA_ENABLED="true"
  else
    LISK_QEMU_GA_ENABLED="false"
  fi
}

# Detects if running inside a container.
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

# Detects CPU model and core count.
_lisk_detect_cpu_info() {
  if [ -f /proc/cpuinfo ]; then
    LISK_CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d ':' -f 2 | sed 's/^[ \t]*//')
    LISK_CPU_CORES=$(grep -c "processor" /proc/cpuinfo)
  else
     LISK_CPU_MODEL="Unknown"
     LISK_CPU_CORES="Unknown"
  fi
}

# Detects total memory size.
_lisk_detect_memory_info() {
  if [ -f /proc/meminfo ]; then
    LISK_MEMORY_TOTAL=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
    # Convert kB to MB
    LISK_MEMORY_TOTAL=$((LISK_MEMORY_TOTAL / 1024))
  else
    LISK_MEMORY_TOTAL="Unknown"
  fi
}

# Detects total disk space.
_lisk_detect_disk_info() {
    # Uses df, excludes tmpfs, devtmpfs, overlay, and none filesystems
    # Calculates total disk space in GB.
    # 2>/dev/null ensures no error output if /proc is unavailable.
    LISK_DISK_TOTAL=$(df -H --total --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=overlay --exclude-type=none 2>/dev/null | tail -n 1 | awk '{print $2}' | sed 's/G//')

  if [ -z "$LISK_DISK_TOTAL" ]; then
     LISK_DISK_TOTAL="Unknown"
  fi
}

# Auto-detects the external IP address.
_lisk_detect_external_ip() {
    LISK_EXTERNAL_IP=$(curl -s -m "$LISK_DOWNLOAD_TIMEOUT" https://ipinfo.io/ip 2>/dev/null)
    if [[ -z "$LISK_EXTERNAL_IP" ]]; then
      # Fallback: ifconfig.io
      LISK_EXTERNAL_IP=$(curl -s -m "$LISK_DOWNLOAD_TIMEOUT" https://ifconfig.io/ip 2>/dev/null)
    fi
    if [ -z "$LISK_EXTERNAL_IP" ]; then
        LISK_EXTERNAL_IP="Unknown"
    fi
}

# Auto-detects the country/region code.
_lisk_detect_country_code() {
  if [ "$LISK_EXTERNAL_IP" != "Unknown" ]; then
    LISK_COUNTRY_CODE=$(curl -s -m "$LISK_DOWNLOAD_TIMEOUT" "https://ipinfo.io/country" 2>/dev/null)
    if [[ -z "$LISK_COUNTRY_CODE" ]]; then
      # Fallback: ifconfig.io
      LISK_COUNTRY_CODE=$(curl -s -m "$LISK_DOWNLOAD_TIMEOUT" "https://ifconfig.io/country_code" 2>/dev/null)
    fi
  fi

  if [ -z "$LISK_COUNTRY_CODE" ]; then
    LISK_COUNTRY_CODE="Unknown"
  fi
}

# Checks network connectivity, can be used for subsequent script downloads and network access, including DNS resolution.
_lisk_check_internet_connection() {
    # Test multiple DNS servers for reliability
    timeout "$LISK_SCRIPT_TIMEOUT" bash -c "</dev/tcp/1.1.1.1/53" 2>/dev/null && return 0
    timeout "$LISK_SCRIPT_TIMEOUT" bash -c "</dev/tcp/8.8.8.8/53" 2>/dev/null && return 0
    timeout "$LISK_SCRIPT_TIMEOUT" bash -c "</dev/tcp/223.5.5.5/53" 2>/dev/null && return 0
    timeout "$LISK_SCRIPT_TIMEOUT" bash -c "</dev/tcp/4.2.2.1/53" 2>/dev/null && return 0
    timeout "$LISK_SCRIPT_TIMEOUT" bash -c "</dev/tcp/2606:4700:4700::1111/53" 2>/dev/null && return 0
    timeout "$LISK_SCRIPT_TIMEOUT" bash -c "</dev/tcp/2400:3200::1/53" 2>/dev/null && return 0
    return 1 # If all checks fail, return 1
}

# Escape special characters in variable values for use in sed.
_lisk_escape_sed() {
  local var_name="$1"
  local var_value="${!var_name}"

  # Escape /, \, &, ", and newlines
  var_value=$(sed 's/[\/&"]/\\&/g; s/\\/\\\\/g; s/\n/\\n/g; s/"/\\"/g' <<< "$var_value")
  printf -v "$var_name" '%s' "$var_value"
}

# Parameter handling: -a (Updates all recommended values)
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
  #_lisk_check_internet_connection  # Network connection check removed from -a

  # Define an array containing all global variables to be updated (only add global variables at the top)
  declare -a vars=(
    LISK_BASE_DIR
    LISK_DISTRO
    LISK_DISTRO_VERSION
    LISK_DISTRO_FAMILY
    LISK_KERNEL_VERSION
    LISK_ARCHITECTURE
    LISK_VIRTUALIZATION
    LISK_TUN_TAP_ENABLED
    LISK_CLOUD_INIT_ENABLED
    LISK_QEMU_GA_ENABLED
    LISK_IS_CONTAINER
    LISK_CPU_MODEL
    LISK_CPU_CORES
    LISK_MEMORY_TOTAL
    LISK_DISK_TOTAL
    LISK_EXTERNAL_IP
    LISK_COUNTRY_CODE
  )

    # 1. Extract global variable definition template
    # shellcheck disable=SC2001
    template=$(sed -n '/^# Global variables/,/^# End of global variables/p' "$0")

    # 2. Replace variable values in the template
    for var in "${vars[@]}"; do
        value="${!var}"
        # shellcheck disable=SC2086
        template=$(sed "s|$var=.*|$var=\"$value\"|" <<< "$template")
    done

    # 3. Write the updated template back to the file
    {
        echo "$template"
        sed '1,/# End of global variables/d' "$0"  # Delete the original global variable section
    } > "$0.tmp" && mv "$0.tmp" "$0"

  exit 0
fi