#!/usr/bin/env bash

# 图标定义 (Nerd Font)
LOCK=""
SUSPEND="󰒲"
LOGOUT="󰍃"
REBOOT="󰜉"
SHUTDOWN="󰐥"

# 选项列表
OPTIONS="$LOCK\n$SUSPEND\n$LOGOUT\n$REBOOT\n$SHUTDOWN"

# 调出 Rofi 选择器
CHOSEN=$(echo -e "$OPTIONS" | rofi -dmenu -theme ~/.config/rofi/powermenu.rasi)

# 执行对应动作 (默认兼容 Hyprland/Sway 与 Systemd)
case "$CHOSEN" in
    "$LOCK")
        # 如果使用 swaylock / hyprlock，按需替换
        if command -v hyprlock &> /dev/null; then
            hyprlock
        elif command -v swaylock &> /dev/null; then
            swaylock
        else
            loginctl lock-session
        fi
        ;;
    "$SUSPEND")
        systemctl suspend
        ;;
    "$LOGOUT")
        hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'
        ;;
    "$REBOOT")
        systemctl reboot
        ;;
    "$SHUTDOWN")
        systemctl poweroff
        ;;
esac
