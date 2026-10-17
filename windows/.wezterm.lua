local wezterm = require 'wezterm'
local act = wezterm.action

-- 将配置表合并到返回的对象中
local config = {}

-- ===========================================================================
-- 1. 键位绑定 (Tmux 风格，Leader 为 Ctrl+b)
-- ===========================================================================

config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 3000 }

config.keys = {
  -- 1. 分屏操作 (Leader + " 或 %)
  -- Leader + \  : 水平分屏 (左右)
  { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  -- Leader + = : 水平分屏 (左右，兼容中文输入法)
  { key = '=', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  -- Leader + - : 垂直分屏 (上下)
  { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- 2. 窗格导航 (Vim 风格 h/j/k/l + 方向键, tmux 风格别称)
  -- Leader + h/l : 左右移动
  -- Leader + j/k : 上下移动
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  -- Leader + 方向键 : 与 h/j/k/l 等效 (更直观, 且不受输入法影响)
  { key = 'LeftArrow',  mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'DownArrow',  mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'UpArrow',    mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'RightArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  -- Leader + Ctrl + h/j/k/l : 带 Ctrl 修饰, 可绕过中文输入法 (中文输入时推荐用这套)
  { key = 'h', mods = 'LEADER|CTRL', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER|CTRL', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER|CTRL', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER|CTRL', action = act.ActivatePaneDirection 'Right' },
  -- Leader + o : 循环切换到下一个窗格 (tmux 风格, 多窗格时快速跳转)
  { key = 'o', mods = 'LEADER', action = act.ActivatePaneDirection 'Next' },
  -- Leader + Ctrl + o : 同上, 绕过中文输入法
  { key = 'o', mods = 'LEADER|CTRL', action = act.ActivatePaneDirection 'Next' },

  -- 3. 窗格大小调整 (Ctrl+Shift+方向键)
  { key = 'LeftArrow',  mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Left',  1 } },
  { key = 'DownArrow',  mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Down',  1 } },
  { key = 'UpArrow',    mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Up',    1 } },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Right', 1 } },

  -- 4. 窗格最大化/还原 (Leader + z)
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

  -- 5. 关闭当前窗格 (Leader + x) -- 可选，防止误按，注释掉了
  -- { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },

  -- 6. Windows Terminal 风格的复制/粘贴
  -- Ctrl+C：有选中文字则复制并清除选区；无选中则原样发送 Ctrl+C（中断信号），
  --         因此跑 coding agent 时选中文字按 Ctrl+C 只复制，不会打断程序。
  {
    key = 'c',
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if sel ~= '' then
        window:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
      end
    end),
  },
  -- Ctrl+V：粘贴剪贴板内容
  {
    key = 'v',
    mods = 'CTRL',
    action = act.PasteFrom 'Clipboard',
  },
}

-- ===========================================================================
-- 2. 界面与外观 (节省空间为核心)
-- ===========================================================================

-- 保留标题栏和窗口缩放边框 (最大化/最小化/关闭按钮 + 可拖拽缩放)
-- 选项: "TITLE", "RESIZE", "NONE", "TITLE|RESIZE"
config.window_decorations = "TITLE|RESIZE"

-- [核心] 只有在打开多个标签页时才显示标签栏，平时隐藏
config.hide_tab_bar_if_only_one_tab = true

-- [核心] 使用原生风格的标签栏 (占用空间更小，更紧凑)
-- 如果想要类似 Chrome 的圆角标签，改为 true
config.use_fancy_tab_bar = true

-- 标签栏显示在底部 (类似 tmux 的状态栏位置)
-- 选项: true (底部), false (顶部)
config.tab_bar_at_bottom = false

-- 增加标签最大宽度，让标签显示更宽松，不那么紧凑
config.tab_max_width = 32

-- 窗口初始大小
config.initial_cols = 120
config.initial_rows = 35

-- 窗口背景透明度 (0.0 ~ 1.0)
config.window_background_opacity = 0.95

-- 窗口内边距 (避免内容贴边)
config.window_padding = {
  left = 8,
  right = 8,
  top = 4,
  bottom = 4,
}

-- ===========================================================================
-- 3. 字体、光标与配色
-- ===========================================================================

-- 字体设置
-- 推荐使用 Nerd Font 字体以支持图标，如果没有安装，系统会自动降级到默认字体
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 10.5

-- 连字设置 (默认开启)
-- 如果不想显示连字 (如 != 变成 ≠)，取消下面这行的注释
-- config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

-- 光标样式
-- 选项: "SteadyBlock", "BlinkingBlock", "SteadyUnderline", "BlinkingUnderline", "SteadyBar", "BlinkingBar"
config.default_cursor_style = 'SteadyBlock'

-- 回滚缓冲区行数 (滚轮能往上翻多少行)
config.scrollback_lines = 10000
-- 显示滚动条
config.enable_scroll_bar = false

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
-- 6. 鼠标绑定 (中键粘贴)
-- ===========================================================================

-- 程序开启鼠标上报(mouse reporting)后会接管鼠标事件,
-- WezTerm 默认的中键粘贴绑定(Single Middle Down)不再触发,
-- 新版 Claude Code CLI 就是这种情况。补两条绑定:
-- 第一条等价于默认行为,程序未接管鼠标时生效;
-- 第二条声明 mouse_reporting = true,程序接管鼠标时仍然执行粘贴。
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Middle' } },
    mods = 'NONE',
    action = act.PasteFrom 'PrimarySelection',
  },
  {
    event = { Down = { streak = 1, button = 'Middle' } },
    mods = 'NONE',
    mouse_reporting = true,
    action = act.PasteFrom 'PrimarySelection',
  },
}

-- ===========================================================================
-- 单实例模式配置
-- ===========================================================================

config.prefer_to_spawn_tabs = true
-- config.unix_domains = {
--   {
--     name = 'unix',
--     socket_path = '\\.\pipe\wezterm-unix-domain',
--   }
-- }
-- config.default_gui_startup_args = { 'connect', 'unix' }

-- disable auto update
config.check_for_updates = false

-- GPU/VM optimization
--config.front_end = "Software"
config.animation_fps = 1
config.cursor_blink_rate = 0
config.max_fps = 60

return config
