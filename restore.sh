#!/usr/bin/env bash
# =============================================================================
# dotfiles restore script
# 从 ~/Work/dotfiles-backup 恢复配置到新系统
# 用法: bash ~/Work/dotfiles-backup/restore.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR"
HOME_DIR="$HOME"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()  { echo -e "\n${CYAN}=== $1 ===${NC}"; }

# Check if backup dir exists
if [ ! -d "$BACKUP_DIR" ]; then
    log_err "Backup directory not found: $BACKUP_DIR"
    exit 1
fi

echo ""
echo "============================================"
echo "  Dotfiles Restore"
echo "  Backup: $BACKUP_DIR"
echo "  Target: $HOME_DIR"
echo "============================================"
echo ""

# Ask for confirmation
read -rp "确认恢复配置? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    log_warn "取消恢复"
    exit 0
fi

# Helper: copy a file/dir from backup to target, with backup of existing
restore_item() {
    local src="$1"
    local dest="$2"
    local desc="$3"

    if [ ! -e "$src" ]; then
        log_warn "  源文件不存在，跳过: $desc"
        return
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        local backup_suffix=".bak-$(date +%Y%m%d%H%M%S)"
        local backup_dest="${dest}${backup_suffix}"
        log_warn "  目标已存在，备份到: $(basename "$backup_dest")"
        mv "$dest" "$backup_dest"
    fi

    cp -a "$src" "$dest"
    log_info "  OK: $desc"
}

# =============================================================================
# Step 1: Create necessary directories
# =============================================================================
log_step "1/6 创建目录结构"

mkdir -p "$HOME_DIR/.config"
mkdir -p "$HOME_DIR/.local/share"
mkdir -p "$HOME_DIR/.local/state"
mkdir -p "$HOME_DIR/.local/bin"
log_info "目录结构创建完成"

# =============================================================================
# Step 2: Restore ~/.config/
# =============================================================================
log_step "2/6 恢复 ~/.config/"

CONFIG_ITEMS=(
    "hypr"
    "waybar"
    "wofi"
    "rofi"
    "niri"
    "fcitx5"
    "fcitx"
    "kitty"
    "nvim"
    "fish"
    "gtk-3.0"
    "gtk-4.0"
    "dconf"
    "xsettingsd"
    "QtProject.conf"
    "menus"
    "autostart"
    "mimeapps.list"
    "user-dirs.dirs"
    "user-dirs.locale"
    "fastfetch"
    "lazygit"
    "Thunar"
    "xfce4"
    "systemd"
    "pavucontrol.ini"
    "quickshell"
    "hypr-overview"
    "nwg-look"
    "com.ccswitch.desktop"
    "io.github.clash-verge-rev.clash-verge-rev"
    "opencode"
    "ssy-music"
    "obs-studio"
    "inkscape"
)

for item in "${CONFIG_ITEMS[@]}"; do
    restore_item "$BACKUP_DIR/.config/$item" "$HOME_DIR/.config/$item" "~/.config/$item"
done

# =============================================================================
# Step 3: Restore home dotfiles
# =============================================================================
log_step "3/6 恢复根目录点文件"

DOTFILE_FILES=(
    ".bashrc"
    ".zshrc"
    ".profile"
    ".gitconfig"
    ".gtkrc-2.0"
    ".nvidia-settings-rc"
    ".wget-hsts"
)

for item in "${DOTFILE_FILES[@]}"; do
    restore_item "$BACKUP_DIR/dotfiles/$item" "$HOME_DIR/$item" "$item"
done

DOTFILE_DIRS=(
    ".ssh"
    ".gnupg"
    ".cargo"
    ".rustup"
    ".pki"
    ".nv"
)

for item in "${DOTFILE_DIRS[@]}"; do
    restore_item "$BACKUP_DIR/dotfiles/$item" "$HOME_DIR/$item" "$item"
done

# .sys1og.conf (may or may not exist)
if [ -f "$BACKUP_DIR/dotfiles/.sys1og.conf" ]; then
    restore_item "$BACKUP_DIR/dotfiles/.sys1og.conf" "$HOME_DIR/.sys1og.conf" ".sys1og.conf"
fi

# =============================================================================
# Step 4: Restore ~/.local/share/
# =============================================================================
log_step "4/6 恢复 ~/.local/share/"

SHARE_ITEMS=(
    "clipman.json"
    "dbus-1"
    "desktop-directories"
    "applications"
    "fcitx5"
    "fish"
    "hyprland"
    "hyprlauncher"
    "opencode"
    "opentui"
    "qalculate"
    "vulkan"
    "sddm"
    "mime"
    "icons"
    "gvfs-metadata"
    "webkitgtk-4.1"
    "nautilus"
    "com.ccswitch.desktop"
    "com.eternity.eternitymusic"
    "com.eternity.eternity_music"
    "com.nebula.karing"
)

for item in "${SHARE_ITEMS[@]}"; do
    restore_item "$BACKUP_DIR/.local/share/$item" "$HOME_DIR/.local/share/$item" ".local/share/$item"
done

# =============================================================================
# Step 5: Restore ~/.local/state/ and ~/.local/bin/
# =============================================================================
log_step "5/6 恢复 ~/.local/state/ 和 ~/.local/bin/"

restore_item "$BACKUP_DIR/.local/state/wireplumber" "$HOME_DIR/.local/state/wireplumber" "wireplumber"
restore_item "$BACKUP_DIR/.local/bin/hypr-overview" "$HOME_DIR/.local/bin/hypr-overview" "hypr-overview"
restore_item "$BACKUP_DIR/.local/bin/workspace" "$HOME_DIR/.local/bin/workspace" "workspace"

# =============================================================================
# Step 6: Post-install steps
# =============================================================================
log_step "6/6 后处理"

# Ensure ~/.local/bin is executable
chmod +x "$HOME_DIR/.local/bin/"* 2>/dev/null || true

# Ensure ~/.ssh has correct permissions
if [ -d "$HOME_DIR/.ssh" ]; then
    chmod 700 "$HOME_DIR/.ssh"
    chmod 600 "$HOME_DIR/.ssh/"* 2>/dev/null || true
    chmod 644 "$HOME_DIR/.ssh"/*.pub 2>/dev/null || true
    log_info ".ssh 权限已修正"
fi

# Ensure ~/.gnupg has correct permissions
if [ -d "$HOME_DIR/.gnupg" ]; then
    chmod 700 "$HOME_DIR/.gnupg"
    log_info ".gnupg 权限已修正"
fi

# Fix ownership (in case run as root or different user)
if [ "$(id -u)" -eq 0 ]; then
    log_warn "以 root 运行，正在修正文件所有权..."
    chown -R "$(logname 2>/dev/null || echo "$SUDO_USER")" "$HOME_DIR/.config" 2>/dev/null || true
    chown -R "$(logname 2>/dev/null || echo "$SUDO_USER")" "$HOME_DIR/.local" 2>/dev/null || true
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "============================================"
echo -e "  ${GREEN}恢复完成!${NC}"
echo "============================================"
echo ""
log_info "以下操作建议:"
echo ""
echo "  1. 重启 shell 使配置生效:"
echo "     exec zsh  (或 exec bash)"
echo ""
echo "  2. 如果安装了 Rust，运行:"
echo "     rustup toolchain install stable"
echo "     cargo build  (项目目录)"
echo ""
echo "  3. Neovim 插件会自动通过 lazy.nvim 安装"
echo "     打开 nvim 等待即可"
echo ""
echo "  4. dconf 配置需要手动导入:"
echo "     dconf load / < ~/.config/dconf/user"
echo ""
echo "  5. fcitx5 配置已恢复，重启输入法即可"
echo ""
echo "  6. 如果某些应用提示权限问题，运行:"
echo "     chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_*"
echo ""
echo "============================================"
echo ""
