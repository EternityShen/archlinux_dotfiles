#!/usr/bin/env bash
# =============================================================================
# Arch Linux 系统初始化脚本
# 从 dotfiles-backup 目录运行: bash ~/Work/dotfiles-backup/install.sh
# 根据 pacman -Qe 和 paru -Qm 导出, 按类别分组
# 用法: sudo bash install.sh  (大部分需要 root)
#       bash install.sh       (部分命令不需要 root)
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_step()  { echo -e "\n${CYAN}=== $1 ===${NC}"; }

# 需要 root 的命令用 $SU 前缀
if [ "$(id -u)" -eq 0 ]; then
    SU=""
    log_info "以 root 运行"
else
    SU="sudo"
    log_info "以普通用户运行 (将使用 sudo)"
fi

# =============================================================================
# 0. 镜像源 & 仓库配置
# =============================================================================
log_step "0/8 配置镜像源 & 仓库"

# 启用 multilib (如果需要)
$SU sed -i '/\[multilib\]/,/Include/' -e 's/^#//' /etc/pacman.conf 2>/dev/null || true

# 添加 archlinuxcn 仓库
if ! grep -q '\[archlinuxcn\]' /etc/pacman.conf 2>/dev/null; then
    $SU tee -a /etc/pacman.conf >/dev/null <<'EOF'

[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$repo/os/$arch
EOF
    log_info "已添加 archlinuxcn 仓库"
else
    log_info "archlinuxcn 仓库已存在"
fi

# 更新密钥环和包数据库
$SU pacman -Sy archlinuxcn-keyring --noconfirm 2>/dev/null || true
$SU pacman -Syu --noconfirm

# 安装 paru (AUR helper)
if ! command -v paru &>/dev/null; then
    log_info "安装 paru..."
    $SU pacman -S --needed --noconfirm base-devel git
    if [ ! -d "$HOME/paru" ]; then
        git clone https://aur.archlinux.org/paru.git "$HOME/paru"
    fi
    cd "$HOME/paru" && makepkg -si --noconfirm
    cd - >/dev/null
    rm -rf "$HOME/paru"
    log_info "paru 安装完成"
else
    paru -Syu --noconfirm
    log_info "paru 已存在, 已更新"
fi

# =============================================================================
# 1. 系统基础包
# =============================================================================
log_step "1/8 系统基础包"

$SU pacman -S --noconfirm \
    base \
    base-devel \
    sudo \
    linux-zen \
    linux-zen-headers \
    linux-firmware \
    amd-ucode \
    sof-firmware \
    grub \
    os-prober \
    efibootmgr \
    btrfs-progs \
    tuned \
    tuned-ppd \
    zram-generator \
    debugedit \
    fakeroot \
    dpkg \
    pkgconf

log_info "系统基础包安装完成"

# =============================================================================
# 2. NVIDIA 显卡驱动
# =============================================================================
log_step "2/8 NVIDIA 显卡驱动"

# 注意: 如果你用的是 AMD 显卡, 跳过此节
$SU pacman -S --noconfirm \
    nvidia-open-dkms \
    nvidia-settings \
    nvidia-utils

log_info "NVIDIA 驱动安装完成"

# =============================================================================
# 3. Wayland / 桌面环境
# =============================================================================
log_step "3/8 Wayland / 桌面环境 (Hyprland + 相关组件)"

$SU pacman -S --noconfirm \
    hyprland-git \
    hyprgraphics-git \
    hyprtoolkit-git \
    hyprlauncher \
    hyprlock \
    hyprpaper \
    xwayland-satellite \
    waybar-git \
    swayidle \
    sddm \
    grim \
    slurp \
    swww-git \
    wofi \
    rofi \
    xdotool \
    x11vnc \
    xorg-server-xvfb \
    xf86-video-fbdev

# niri (备用 Wayland compositor) - AUR
paru -S --noconfirm niri-git 2>/dev/null || log_warn "niri-git 安装失败"

# wlogout - AUR
paru -S --noconfirm wlogout 2>/dev/null || log_warn "wlogout 安装失败"

log_info "Wayland 组件安装完成"

# =============================================================================
# 4. 终端 / Shell / 编辑器
# =============================================================================
log_step "4/8 终端 / Shell / 编辑器"

$SU pacman -S --noconfirm \
    kitty \
    ghostty \
    fish \
    zsh \
    fastfetch \
    lazygit \
    tree \
    yazi \
    fd \
    ripgrep \
    chafa \
    fuzzel \
    cliphist \
    neovim \
    tree-sitter-cli \
    tree-sitter-rust

# 启用 zsh + Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_info "安装 Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_info "Oh My Zsh 安装完成"
fi

log_info "终端/Shell/编辑器安装完成"

# =============================================================================
# 5. 输入法 & 区域设置
# =============================================================================
log_step "5/8 输入法 (fcitx5)"

$SU pacman -S --noconfirm \
    fcitx5 \
    fcitx5-configtool \
    fcitx5-rime \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-hyprland

# fcitx5-themes-macos - AUR
paru -S --noconfirm fcitx5-themes-macos-git 2>/dev/null || log_warn "fcitx5-themes-macos-git 安装失败"

log_info "输入法安装完成"

# =============================================================================
# 6. 音频 / 网络 / 蓝牙
# =============================================================================
log_step "6/8 音频 / 网络 / 蓝牙"

$SU pacman -S --noconfirm \
    pipewire \
    pipewire-alsa \
    pipewire-jack \
    pipewire-pulse \
    wireplumber \
    pavucontrol \
    libpulse \
    networkmanager \
    wpa_supplicant \
    bluez \
    bluez-utils \
    gst-libav \
    gst-plugin-pipewire \
    gst-plugins-bad \
    gst-plugins-base \
    gst-plugins-good

log_info "音频/网络/蓝牙安装完成"

# =============================================================================
# 7. 主题 / 图标 / 字体
# =============================================================================
log_step "7/8 主题 / 图标 / 字体"

$SU pacman -S --noconfirm \
    papirus-icon-theme \
    appmenu-gtk-module \
    gnome-software \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    ttf-dejavu \
    ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd \
    ttf-nerd-fonts-symbols \
    ttf-nerd-fonts-symbols-mono

# Catppuccin 主题 - AUR
paru -S --noconfirm catppuccin-gtk-theme-mocha 2>/dev/null || log_warn "catppuccin-gtk-theme-mocha 安装失败"

# Nordic 主题 - AUR
paru -S --noconfirm nordic-theme-git 2>/dev/null || log_warn "nordic-theme-git 安装失败"

# Noctalia (颜色方案引擎) - AUR
paru -S --noconfirm noctalia-git noctalia-shell 2>/dev/null || log_warn "noctalia 安装失败"

# 自定义光标 - AUR
paru -S --noconfirm breeze-cursors-lh breezex-cursor-theme 2>/dev/null || log_warn "breeze cursors 安装失败"

log_info "主题/图标/字体安装完成"

# =============================================================================
# 8. 开发工具 / 浏览器 / 其他
# =============================================================================
log_step "8/8 开发工具 / 浏览器 / 其他"

# 通用工具
$SU pacman -S --noconfirm \
    wget \
    unzip \
    fuse2 \
    ufw \
    fmt \
    libc++ \
    libc++abi \
    nodejs \
    pnpm \
    uv \
    python312 \
    python-pip \
    python-pipx \
    rust-analyzer \
    openjdk17-src \
    vue-language-server \
    scrcpy \
    android-tools \
    ddcutil

# Go
$SU pacman -S --noconfirm go

# 浏览器 (可选, 按需取消注释)
# $SU pacman -S --noconfirm firefox
# paru -S --noconfirm google-chrome 2>/dev/null || true
# paru -S --noconfirm microsoft-edge-stable-bin 2>/dev/null || true

# Steam / Wine (可选)
$SU pacman -S --noconfirm steam wine wine-mono

# 中文应用 - AUR
paru -S --noconfirm \
    cc-switch \
    clash-verge-rev-bin \
    spark-store \
    dgop \
    daed \
    bili-live-hime \
    stelliberty-bin \
    gemini-desktop-git \
    telegram-desktop-bin \
    opencode-desktop-bin 2>/dev/null || log_warn "部分 AUR 包安装失败, 请手动安装"

# AI 工具 - AUR
paru -S --noconfirm \
    litellm \
    sentencepiece \
    amber-package-manager 2>/dev/null || log_warn "AI 工具安装失败"

# VS Code (可选, 注释中)
# paru -S --noconfirm visual-studio-code-bin 2>/dev/null || true

# opencode CLI
$SU pacman -S --noconfirm opencode

log_info "开发工具安装完成"

# =============================================================================
# 后处理: npm 全局包 & 服务启用
# =============================================================================
log_step "后处理"

# npm 全局包
npm install -g hexo-cli 2>/dev/null || log_warn "hexo-cli 安装失败"

# 启用服务
$SU systemctl enable sddm
$SU systemctl enable NetworkManager
$SU systemctl enable bluetooth
$SU systemctl enable tuned

# 启用用户服务
systemctl --user enable hyprpaper 2>/dev/null || true
systemctl --user enable clipman 2>/dev/null || true

# =============================================================================
# 完成
# =============================================================================
echo ""
echo "============================================"
echo -e "  ${GREEN}软件包安装完成!${NC}"
echo "============================================"
echo ""
echo "后续步骤:"
echo ""
echo "  1. 恢复配置:"
echo "     bash ~/Work/dotfiles-backup/restore.sh"
echo ""
echo "  2. 设置默认 shell 为 zsh:"
echo "     chsh -s $(which zsh)"
echo ""
echo "  3. 重启系统:"
echo "     reboot"
echo ""
echo "  4. 如果 Grub 未安装, 手动运行:"
echo "     sudo grub-install"
echo "     sudo grub-mkconfig -o /boot/grub/grub.cfg"
echo ""
echo "  5. 如果使用双系统, 运行:"
echo "     sudo os-prober && sudo grub-mkconfig -o /boot/grub/grub.cfg"
echo ""
echo "  6. 如果遇到 AUR 包安装失败, 可以单独运行:"
echo "     paru -S <包名>"
echo ""
echo "============================================"
