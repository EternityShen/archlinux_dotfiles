-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- 自动生成的 Hyprland 配置文件。                        --
-- 请根据 Wiki 说明编辑此配置文件。                      --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- 这是一个 Hyprland Lua 配置示例文件。
-- 更多信息请参考 Wiki：https://wiki.hypr.land/Configuring/Start/
--
-- 注意：并非所有可用的设置/选项都在此处列出。
-- 完整列表请查看 Wiki。
--
-- 你可以（而且应该！！）将此配置拆分为多个文件。
-- 分别创建你的文件，然后像这样引入它们：
-- require("myColors")

------------------
---- 显示器配置 ----
------------------

-- 参考：https://wiki.hypr.land/Configuring/Basics/Monitors/
-- 设置显示器输出参数，output="" 表示自动检测，mode 使用首选分辨率，position 自动，scale 自动。
-- hl.monitor({
--   output   = "",          -- 显示器名称，空字符串表示自动选择
--   mode     = "preferred", -- 分辨率/刷新率模式，'preferred' 使用系统推荐值
--   position = "auto",      -- 显示器位置（相对其他显示器），'auto' 自动排列
--   scale    = "auto",      -- 缩放比例，'auto' 自动适配
-- })

-- 内屏在左
hl.monitor({
  output   = "eDP-2",
  mode     = "2560x1600@165",
  position = "0x200",
  scale    = 1.33
})

-- 外接在右（从 2560 开始）
hl.monitor({
  output   = "HDMI-A-1",
  mode     = "1920x1080@60",
  position = "-1920x0", -- 因为内屏宽 2560
  scale    = 1,
})

---------------------
---- 我的程序 ----
---------------------

-- 设置你常用的程序路径，方便在快捷键中引用
local terminal    = "kitty"            -- 终端模拟器
local fileManager = "nautilus"         -- 文件管理器
local menu        = "wofi --show drun" -- 应用启动菜单

-------------------
---- 自动启动 ----
-------------------

-- 参考：https://wiki.hypr.land/Configuring/Basics/Autostart/
--
-- 自动启动必要进程（如通知守护进程、状态栏等）。
-- 或者像下面这样在 Hyprland 启动时执行你喜欢的应用：
--
hl.on("hyprland.start", function()
  hl.exec_cmd("waybar")
  hl.exec_cmd("swww-daemon")
  hl.exec_cmd("fcitx5")
  hl.exec_cmd("clash-verge")
  hl.exec_cmd("hypr-overview")
  hl.exec_cmd("sleep 1 && swww img \"/home/eternity/Pictures/Image_1777541053459_272..jpg\"");
  hl.exec_cmd("bash -c 'WLR_NO_HARDWARE_CURSORS=1 wl-paste --watch /home/eternity/bin/clipman store &'")
  hl.exec_cmd("swayidle -w")
  -- 预创建工作区 1~10，waybar 点击才能切换
  for i = 1, 10 do
    hl.dispatch(hl.dsp.focus({ workspace = i }))
  end
  hl.dispatch(hl.dsp.focus({ workspace = 1 }))
end)

-------------------------------
---- 环境变量 ----
-------------------------------

-- 参考：https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
-- 设置光标大小等环境变量，影响 Hyprland 和 XWayland 应用
hl.env("XCURSOR_SIZE", "24")               -- X11 光标大小
hl.env("XCURSOR_THEME", "BreezeX-Dark")    -- X11 光标主题
hl.env("HYPRCURSOR_THEME", "BreezeX-Dark") -- Hyprland 原生光标主题
hl.env("HYPRCURSOR_SIZE", "24")            -- Hyprland 原生光标大小

-----------------------
----- 权限设置 -----
-----------------------

-- 参考：https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- 注意：权限更改需要重启 Hyprland 才能生效，且不会即时应用，出于安全考虑。

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,   -- 启用权限强制检查
--   },
-- })

-- 为特定程序授予特定权限（如截屏、插件等）
-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")

hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- 外观与感觉 ----
-----------------------

-- 参考：https://wiki.hypr.land/Configuring/Basics/Variables/
-- 常规窗口、边框、间距、布局等全局设置
hl.config({
  general = {
    gaps_in          = 3,                                                                                   -- 窗口之间的内边距（像素）
    gaps_out         = 6,                                                                                   -- 窗口与屏幕边缘的外边距（像素）

    border_size      = 2,                                                                                   -- 窗口边框粗细

    col              = {                                                                                    -- 边框颜色配置
      active_border   = { colors = { "rgba(194, 24, 140, 1.0)", "rgba(255, 182, 193, 1.0)" }, angle = 45 }, -- 活动窗口边框渐变色及角度
      inactive_border = "rgba(255, 100, 130, 1.0)",                                                         -- 非活动窗口边框颜色
    },

    -- 设为 true 允许通过点击并拖动边框或间隙来调整窗口大小
    resize_on_border = false,

    -- 在开启撕裂（tearing）之前请阅读相关文档：https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
    allow_tearing    = false,

    layout           = "dwindle", -- 默认布局模式（scrolling, dwindle, master 等）
  },

  decoration = {
    rounding         = 10, -- 窗口圆角半径（像素）
    rounding_power   = 2,  -- 圆角幂次（影响圆角曲线形状）

    -- 更改焦点窗口和非焦点窗口的透明度（1.0 为不透明）
    active_opacity   = 0.9,
    inactive_opacity = 0.8,

    shadow           = {         -- 阴影设置
      enabled      = true,
      range        = 4,          -- 阴影扩散范围
      render_power = 3,          -- 渲染幂次（影响阴影衰减）
      color        = 0xee1a1a1a, -- 阴影颜色（ARGB 格式）
    },

    blur             = { -- 模糊效果（适用于背景透明窗口）
      enabled  = true,
      size     = 3,      -- 模糊半径
      passes   = 1,      -- 模糊渲染次数（越高越平滑但性能消耗大）
      vibrancy = 0.1696, -- 鲜艳度（色彩饱和度增强）
    },
  },

  animations = {
    enabled = true, -- 是否启用窗口动画
  },

  xwayland = {
    force_zero_scaling = true
  }
})

-- 默认曲线和动画配置，详见：https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
-- 定义贝塞尔曲线或弹簧动画曲线
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- 默认弹簧曲线（用于物理动画）
hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

-- 各种动画效果的配置，每个叶子（leaf）代表一种动画类型
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 6, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 6, bezier = "easeOutQuint", style = "slideFadeDir" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- 工作区规则参考：https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- “智能间距” / “仅单窗口时无间距”
-- 如需使用，请取消注释以下内容。
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- Dwindle 布局配置，详见：https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
hl.config({
  dwindle = {
    preserve_split = true, -- 保留分割方向，方便后续调整
  },
})

-- Master 布局配置，详见：https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
hl.config({
  master = {
    new_status = "master", -- 新窗口默认作为主窗口（master）
  },
})

-- Scrolling 布局配置，详见：https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
hl.config({
  scrolling = {
    fullscreen_on_one_column = true, -- 当只有一个列时自动全屏
  },
})

----------------
---- 杂项 ----
----------------

hl.config({
  misc = {
    force_default_wallpaper = -1,    -- 设为 0 或 1 可禁用动漫吉祥物壁纸（-1 表示默认随机）
    disable_hyprland_logo   = false, -- 设为 true 则禁用 Hyprland logo / 动漫女孩背景（默认为 false）
  },
})

---------------
---- 输入设备 ----
---------------

hl.config({
  input = {
    kb_layout    = "us", -- 键盘布局（美国）
    kb_variant   = "",   -- 键盘变体（如 dvorak）
    kb_model     = "",   -- 键盘型号
    kb_options   = "",   -- 键盘选项（如 caps:swapescape）
    kb_rules     = "",   -- 键盘规则文件

    follow_mouse = 1,    -- 鼠标跟随模式（0=禁用，1=焦点跟随鼠标，2=鼠标跟随焦点）

    sensitivity  = -0.1, -- 鼠标灵敏度（-1.0 ~ 1.0，0 表示无调整）

    touchpad     = {
      natural_scroll = false, -- 触控板自然滚动（反向滚动）
    },
  },
})

-- 手势配置（三指水平滑动切换工作区）
hl.gesture({
  fingers = 3,              -- 手指数量
  direction = "horizontal", -- 滑动方向
  action = "workspace"      -- 动作：切换工作区
})


-- 按设备单独配置示例，详见：https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
hl.device({
  name        = "epic-mouse-v1", -- 设备名称（可通过 hyprctl devices 查看）
  sensitivity = -0.5,            -- 为该设备单独设置灵敏度
})

---------------------
---- 键盘快捷键 ----
---------------------

local mainMod = "SUPER" -- 将 Windows 键设为主修饰键（即 Super 键）

-- 示例快捷键，详见：https://wiki.hypr.land/Configuring/Basics/Binds/
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal))                -- 打开终端
local closeWindowBind = hl.bind(mainMod .. " + q", hl.dsp.window.close()) -- 关闭当前窗口
-- closeWindowBind:set_enabled(false)  -- 可禁用该绑定
hl.bind(mainMod .. " + M",
  hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
-- 退出 Hyprland（优先使用 hyprshutdown，否则 fallback）
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))                            -- 打开文件管理器
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))              -- 切换当前窗口浮动状态
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" })) -- 切换当前窗口全屏
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))                                   -- 打开应用启动器
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"), { locked = true })           -- 锁屏
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("WLR_NO_HARDWARE_CURSORS=1 /home/eternity/bin/clipman pick --tool=wofi -T='-p Clip History'"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("WLR_NO_HARDWARE_CURSORS=1 /home/eternity/bin/clipman clear --all"),
  { locked = true })                                  -- 切换伪平铺（pseudo-tile）模式
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))                            -- 切换分割方式（仅 dwindle 布局有效）

-- 使用主修饰键 + 方向键移动焦点
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- 将当前窗口与相邻窗口交换位置
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.move({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ workspace = "+1" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.focus({ workspace = "-1" }))

-- 使用主修饰键 + 数字键 [0-9] 切换工作区
-- 使用主修饰键 + Shift + 数字键 将当前窗口移动到对应工作区
for i = 1, 10 do
  local key = i % 10 -- 10 映射为键 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- 特殊工作区（暂存区，scratchpad）示例
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))                                               -- 切换名为 magic 的特殊工作区
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))  -- 移动窗口到特殊工作区
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("bash -c 'mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png | wl-copy'"),
  { locked = true })                                                                                                    -- 区域截屏并保存到 ~/Pictures/Screenshots/
hl.bind(mainMod .. " + tab", hl.dsp.exec_cmd("qs -p ~/.config/quickshell/hypr-overview ipc call overview toggle")) -- 切换工作区概览

-- 使用主修饰键 + 鼠标滚轮在工作区之间滚动
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "+1" })) -- 下一个工作区
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "-1" }))   -- 上一个工作区

-- 使用主修饰键 + 左键/右键拖动来移动/调整窗口大小
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })   -- 272 = 左键
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true }) -- 273 = 右键

-- 笔记本多媒体键：音量控制和亮度调节
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true })                                                                                  -- 提高音量，限制最大 100%
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true })                                                                                  -- 降低音量
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true })                                                                                  -- 静音切换
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true })                                                                                  -- 麦克风静音切换
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })   -- 增加屏幕亮度
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true }) -- 降低屏幕亮度

-- 媒体控制（需安装 playerctl）
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })        -- 下一曲
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true }) -- 播放/暂停
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })    -- 上一曲

--------------------------------
---- 窗口和工作区规则 ----
--------------------------------

-- 参考：https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- 以及 https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- 一些有用的窗口规则示例

-- local suppressMaximizeRule = hl.window_rule({
--   -- 忽略所有应用的最大化请求，你可能喜欢这个功能
--   name           = "suppress-maximize-events",
--   match          = { class = ".*" }, -- 匹配所有窗口类
--
--   suppress_event = "maximize",       -- 阻止最大化事件
-- })
-- suppressMaximizeRule:set_enabled(false)  -- 可禁用该规则

hl.window_rule({
  -- 修复 XWayland 下的一些拖拽问题
  name     = "fix-xwayland-drags",
  match    = {
    class      = "^$", -- 空类名（匹配特定情况）
    title      = "^$", -- 空标题
    xwayland   = true, -- 仅适用于 XWayland 窗口
    float      = true, -- 必须为浮动窗口
    fullscreen = false,
    pin        = false,
  },

  no_focus = true, -- 防止这些窗口获取焦点
})

-- 图层（layer）规则也会返回句柄，可控制覆盖层等
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,       -- 禁用该图层的动画
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run（运行对话框）窗口规则
hl.window_rule({
  name  = "move-wofi",
  match = { class = "wofi" },

  move  = "20 monitor_h-120",
  float = true,
})
