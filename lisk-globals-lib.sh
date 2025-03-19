#!/bin/bash

# lisk-globals-lib.sh: LISK 通用 shell 函数库

# 引入全局变量
# shellcheck disable=SC1090,SC1091
. "$(dirname "${BASH_SOURCE[0]}")/lisk-globals-env.sh"

# 日志记录函数
# 使用方法: LISK_log_info "This is an informational message."
#           LISK_log_warn "This is a warning message."
#           LISK_log_error "This is an error message."
#           LISK_log_debug "This is a debug message." (仅当 LISK_LOG_LEVEL=DEBUG 时输出)

LISK_log_info() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') INFO: $1" >> "$LISK_LOG_FILE"
}

LISK_log_warn() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') WARN: $1" | tee -a "$LISK_LOG_FILE" >&2
}

LISK_log_error() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: $1" | tee -a "$LISK_LOG_FILE" >&2
}

LISK_log_debug() {
  if [ "$LISK_LOG_LEVEL" = "DEBUG" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') DEBUG: $1" | tee -a "$LISK_LOG_FILE" >&2
  fi
}

# 错误处理函数
# 使用方法: LISK_check_error "Error message" [exit_code]
LISK_check_error() {
  local error_message="$1"
  local exit_code="${2:-1}"  # 默认退出代码为 1

  if [ $? -ne 0 ]; then
    LISK_log_error "$error_message (Script: ${BASH_SOURCE[0]}, Line: $LINENO)"
    exit "$exit_code"
  fi
}

# 执行命令并检查返回值
# 使用方法: LISK_run_command "command" "Error message if command fails"
LISK_run_command() {
  local command="$1"
  local error_message="$2"

  "$command"
  LISK_check_error "$error_message"
}

# 检查依赖项是否安装
# 使用方法: LISK_check_dependency "command" "Error message if command is not found"
LISK_check_dependency() {
  local command_name="$1"
  local error_message="$2"

  if ! command -v "$command_name" &> /dev/null; then
    LISK_log_error "$error_message"
    exit 1
  fi
}

# 下载文件 (支持重试、校验)
# 使用方法: LISK_download_file "URL" "Local file path" [checksum_type] [checksum_value]
LISK_download_file() {
    local url="$1"
    local local_path="$2"
    local checksum_type="$3"
    local checksum_value="$4"
    local downloader="$LISK_DEFAULT_DOWNLOADER"
    local retries="$LISK_MAX_RETRIES"
    local temp_file

    temp_file=$(mktemp -p "$LISK_TEMP_DIR" "lisk_download_XXXXXX") || {
        LISK_log_error "Failed to create temporary file."
        return 1
    }

    while [ $retries -gt 0 ]; do
        case "$downloader" in
            curl)
                curl -s -# -m "$LISK_DOWNLOAD_TIMEOUT" -L "$url" -o "$temp_file"
                ;;
            wget)
                wget -q --progress=bar:force -T "$LISK_DOWNLOAD_TIMEOUT" -O "$temp_file" "$url"
                ;;
            aria2c)
                aria2c --quiet=true --timeout="$LISK_DOWNLOAD_TIMEOUT" --max-tries=1 --dir="$(dirname "$temp_file")" --out="$(basename "$temp_file")" "$url"
                ;;
            *)
                LISK_log_error "Unsupported downloader: $downloader"
                rm -f "$temp_file"
                return 1
                ;;
        esac

        if [ $? -eq 0 ]; then  # 下载成功
            if [ -n "$checksum_type" ] && [ -n "$checksum_value" ]; then
                # 校验文件
                case "$checksum_type" in
                    md5)
                        actual_checksum=$(md5sum "$temp_file" | awk '{print $1}')
                        ;;
                    sha1)
                        actual_checksum=$(sha1sum "$temp_file" | awk '{print $1}')
                        ;;
                    sha256)
                        actual_checksum=$(sha256sum "$temp_file" | awk '{print $1}')
                        ;;
                    *)
                        LISK_log_error "Unsupported checksum type: $checksum_type"
                        rm -f "$temp_file"
                        return 1
                        ;;
                esac

                if [ "$actual_checksum" != "$checksum_value" ]; then
                    LISK_log_error "Checksum mismatch for downloaded file: $local_path"
                    rm -f "$temp_file"
                else
                    # 校验成功
                    mv "$temp_file" "$local_path"
                    return 0  # 成功返回
                fi
            else
                # 不需要校验
                mv "$temp_file" "$local_path"
                return 0 # 成功返回
            fi
        fi

        retries=$((retries - 1))
        LISK_log_warn "Download failed, retrying ($retries retries remaining)..."
        sleep 1 # 等待 1 秒再重试
    done

    LISK_log_error "Failed to download file after multiple retries: $url"
    rm -f "$temp_file"
    return 1
}
# 安装软件包 (支持多种 Linux 发行版)
LISK_install_packages() {
    local packages="$1"
    local install_cmd=""

    case "$LISK_DISTRO_FAMILY" in
        Debian)
            install_cmd="apt update && apt install -y"
            ;;
        RHEL)
            install_cmd="dnf install -y"
            ;;
        SUSE)
            install_cmd="zypper install -y"
            ;;
        Alpine)
            install_cmd="apk add"
            ;;
        Arch)
            install_cmd="pacman -Syu --noconfirm"
            ;;
        *)
            LISK_log_error "Unsupported distribution family: $LISK_DISTRO_FAMILY"
            return 1
            ;;
    esac

    if [ -z "$install_cmd" ]; then
        LISK_log_error "No package installation command defined for distribution family: $LISK_DISTRO_FAMILY"
        return 1
    fi

    if [ -z "$packages" ] ;then
        return 0
    fi

    # 使用 sudo 执行安装命令,所有操作必须以 root 权限执行。
    sudo $install_cmd $packages
}

# 卸载软件包 (支持多种 Linux 发行版)
# Usage: LISK_uninstall_packages "package1 package2 ..."
LISK_uninstall_packages() {
    local packages="$1"
    local uninstall_cmd=""

    case "$LISK_DISTRO_FAMILY" in
        Debian)
            uninstall_cmd="apt remove -y"
            ;;
        RHEL)
            uninstall_cmd="dnf remove -y"
            ;;
        SUSE)
            uninstall_cmd="zypper remove -y"
            ;;
        Alpine)
            uninstall_cmd="apk del"
            ;;
        Arch)
            uninstall_cmd="pacman -R --noconfirm"
            ;;
        *)
            LISK_log_error "Unsupported distribution family: $LISK_DISTRO_FAMILY"
            return 1
            ;;
    esac

    if [ -z "$uninstall_cmd" ]; then
        LISK_log_error "No package uninstallation command defined for distribution family: $LISK_DISTRO_FAMILY"
        return 1
    fi

    if [ -z "$packages" ]; then
        return 0  # 没有要卸载的软件包，直接返回成功
    fi

    # 使用 sudo 执行卸载命令
    sudo $uninstall_cmd $packages
}

# 显示进度条
LISK_show_progress() {
    local current="$1"
    local total="$2"
    local bar_width="${3:-50}"
    local percentage=$((current * 100 / total))
    local filled_width=$((current * bar_width / total))
    local empty_width=$((bar_width - filled_width))

    # 构建进度条字符串
    local bar="["
    printf -v filled_part '%*s' "$filled_width" ''
    bar+="${filled_part// /#}"

    printf -v empty_part '%*s' "$empty_width" ''
    bar+="${empty_part// /=}"

    bar+="]"

    printf "\r%s %3d%%" "$bar" "$percentage"

    # 如果完成，打印换行符
    if [ "$current" -eq "$total" ]; then
        echo
    fi
}

# 确认操作
LISK_confirm() {
  local prompt="$1"
  local default="${2:-n}"  # 默认答案为 "n" (no)

  while true; do
    read -r -p "$prompt (y/n) [default: $default]: " response
    case "$response" in
      [Yy]*) return 0 ;;  # 返回 0 表示确认
      [Nn]*) return 1 ;;  # 返回 1 表示取消
      "")
        if [[ "$default" == [Yy] ]]; then
          return 0
        else
          return 1
        fi
        ;;
      *) echo "Invalid input. Please enter 'y' or 'n'." ;;
    esac
  done
}

# 字符串替换
LISK_string_replace() {
  local string="$1"
  local old="$2"
  local new="$3"
  echo "${string//$old/$new}"
}

# 检查数组是否包含某个元素
LISK_array_contains() {
  local array_name="$1"
  local search_term="$2"
  local element
  for element in "${!array_name[@]}"; do
    if [[ "$element" == "$search_term" ]]; then
      return 0  # 找到，返回 0
    fi
  done
  return 1  # 未找到，返回 1
}