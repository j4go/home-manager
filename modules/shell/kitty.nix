#     __   _ __  __
#    / /__(_) /_/ /___  __
#   / //_/ / __/ __/ / / /
#  / ,< / / /_/ /_/ /_/ /
# /_/|_/_/\__/\__/\__, /
#                /____/
{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    themeFile = "everforest_dark_medium"; # 主题

    # 1. 字体配置 (建议确保字体已在系统安装，如 Maple Mono NF CN)
    font = {
      name = "Maple Mono NF CN";
      size = 13.0;
    };

    # 2. 核心设置映射
    settings = {
      # 视觉与 UI
      window_padding_width = 12;
      hide_window_decorations = "titlebar-only";
      background_opacity = "0.98";

      # 标签页 (Powerline 风格)
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{index}: {title}";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";

      # macOS 深度适配
      macos_option_as_alt = "yes";
      confirm_os_window_close = 0;
      macos_quit_when_last_window_closed = "no";
      macos_thicken_font = "0.45";

      # 鼠标行为
      copy_on_select = "yes";
      strip_trailing_spaces = "smart";

      # 兼容性
      shell_integration = "enabled";
      term = "xterm-kitty";
    };

    # 3. 快捷键映射 (Keymaps)
    keybindings = {
      # 模拟 Mac 习惯与屏蔽
      "cmd+z" = "no_op";
      "cmd+x" = "no_op";
      "alt+x" = "no_op";

      # 标签页管理
      "cmd+t" = "new_tab";
      "cmd+w" = "close_tab";
      "cmd+shift+]" = "next_tab";
      "cmd+shift+[" = "previous_tab";
      "cmd+1" = "goto_tab 1";
      "cmd+2" = "goto_tab 2";
      "cmd+3" = "goto_tab 3";
      "cmd+4" = "goto_tab 4";
      "cmd+5" = "goto_tab 5";
      "cmd+6" = "goto_tab 6";

      # 分屏与窗口
      "cmd+d" = "launch --location=vsplit --cwd=current";
      "cmd+shift+d" = "launch --location=hsplit --cwd=current";
      "cmd+enter" = "new_window";

      # 剪贴板
      "cmd+c" = "copy_to_clipboard";
      "cmd+v" = "paste_from_clipboard";

      # 快捷重载
      "ctrl+cmd+," = "load_config_file";
    };

    # 4. 鼠标映射 (Mouse Maps)
    extraConfig = ''
      mouse_map right press ungrabbed mouse_selection extend
      mouse_map left doublepress ungrabbed mouse_selection word
      mouse_map left triplepress ungrabbed mouse_selection line
      mouse_map cmd+left release grabbed,ungrabbed mouse_handle_click link
    '';
  };
}
