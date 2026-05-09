local wezterm = require 'wezterm'
local act = wezterm.action

-- 将配置表合并到返回的对象中
local config = {}

-- ===========================================================================
-- 1. 键位绑定 (Tmux 风格，Leader 为 Ctrl+b)
-- ===========================================================================

config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- 1. 分屏操作 (Leader + " 或 %)
  -- Leader + \  : 水平分屏 (左右)
  { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  -- Leader + - : 垂直分屏 (上下)
  { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- 2. 窗格导航 (Vim 风格 h/j/k/l)
  -- Leader + h/l : 左右移动
  -- Leader + j/k : 上下移动
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- 3. 窗格大小调整 (Ctrl+Shift+方向键)
  { key = 'LeftArrow',  mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Left',  1 } },
  { key = 'DownArrow',  mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Down',  1 } },
  { key = 'UpArrow',    mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Up',    1 } },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Right', 1 } },

  -- 4. 窗格最大化/还原 (Leader + z)
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

  -- 5. 关闭当前窗格 (Leader + x) -- 可选，防止误按，注释掉了
  -- { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
}

-- ===========================================================================
-- 2. 界面与外观 (节省空间为核心)
-- ===========================================================================

-- [核心] 去掉顶部标题栏和菜单栏，只保留极细边框
-- 这解决了你觉得“标签上面还有菜单栏浪费空间”的问题
-- 选项: "TITLE", "RESIZE", "NONE", "TITLE|RESIZE"
config.window_decorations = "TITLE|RESIZE"

-- [核心] 只有在打开多个标签页时才显示标签栏，平时隐藏
config.hide_tab_bar_if_only_one_tab = false

-- [核心] 使用原生风格的标签栏 (占用空间更小，更紧凑)
-- 如果想要类似 Chrome 的圆角标签，改为 true
config.use_fancy_tab_bar = true

-- 标签栏显示在底部 (类似 tmux 的状态栏位置)
-- 选项: true (底部), false (顶部)
config.tab_bar_at_bottom = true

-- 窗口初始大小
config.initial_cols = 120
config.initial_rows = 35

-- 窗口背景透明度 (0.0 ~ 1.0) -- 可选，不喜欢透明请注释掉
config.window_background_opacity = 0.85

-- ===========================================================================
-- 3. 字体、光标与配色
-- ===========================================================================

-- 字体设置
-- 推荐使用 Nerd Font 字体以支持图标，如果没有安装，系统会自动降级到默认字体
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 11.0

-- 连字设置 (默认开启)
-- 如果不想显示连字 (如 != 变成 ≠)，取消下面这行的注释
-- config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

-- 光标样式
-- 选项: "SteadyBlock", "BlinkingBlock", "SteadyUnderline", "BlinkingUnderline", "SteadyBar", "BlinkingBar"
config.default_cursor_style = 'SteadyBlock'

-- 回滚缓冲区行数 (滚轮能往上翻多少行)
config.scrollback_lines = 10000
-- 显示滚动条
config.enable_scroll_bar = true

-- 配色方案
-- 内置方案预览: https://wezfurlong.org/wezterm/colorschemes/index.html
-- 热门推荐: "Catppuccin-Mocha", "Dracula", "Tokyo Night", "Gruvbox Dark", "OneHalfDark"
config.color_scheme = 'Dracula'

-- ===========================================================================
-- 4. 启动菜单 (Launch Menu)
-- ===========================================================================

-- 右键标签栏选择 "New Window..." 或按 Ctrl+Shift+L 可调出菜单
config.launch_menu = {
  {
    label = 'CMD',
    args = { 'cmd.exe' },
  },
  {
    label = 'PowerShell',
    args = { 'powershell.exe' },
  },
  {
    label = 'Git Bash',
    -- 请确保 Git 安装路径正确，默认一般在 Program Files 下
    args = { 'C:\\Program Files\\Git\\bin\\bash.exe', '-i', '-l' },
  },
  {
    label = 'VS2017 x86 Native Tools',
    -- 请根据你的 VS2017 实际安装路径修改下方路径
    -- 通常在 C:\Program Files (x86)\Microsoft Visual Studio\2017\... 下
    args = {
      'cmd.exe',
      '/k',
      'C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Enterprise\\VC\\Auxiliary\\Build\\vcvarsall.bat',
      'x86'
    },
  },
}

-- ===========================================================================
-- 5. 其他体验优化
-- ===========================================================================

-- 关闭最后一个窗格时不要关闭整个窗口 (防止误关)
config.quit_when_all_windows_are_closed = true

-- 关闭标签页时，自动切换到上次活动的标签页
config.switch_to_last_active_tab_when_closing_tab = true

-- 开启选中复制 (鼠标选中文字自动复制到剪贴板)
config.selection_word_boundary = ' \t\n{}[]()"\''

-- ===========================================================================
-- 单实例模式配置
-- ===========================================================================

config.prefer_to_spawn_tabs = true
-- config.unix_domains = {
--   {
--     name = 'unix',
--     socket_path = '\\\\.\\pipe\\wezterm-unix-domain',
--   }
-- }
-- config.default_gui_startup_args = { 'connect', 'unix' }

-- disable auto update
config.check_for_updates = false

-- GPU/VM optimization
--config.front_end = "Software"
config.animation_fps = 1
config.cursor_blink_rate = 0

return config
