{
  pkgs,
  lib,
  ...
}: let
  # 1. 插件源码 (需修正 Hash)
  yazi-plugins-src = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "88990a6";
    # 🔴 首次构建报错时，请替换为提示的正确 sha256
    hash = "sha256-B9b6T9/RkJDkehMC5/MxqnkjxWj5LZg4jehAn6aeamE=";
  };

  # 2. 主题源码 (需修正 Hash)
  catppuccin-flavor-src = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "9e053d0";
    # 🔴 首次构建报错时，请替换为提示的正确 sha256
    hash = "sha256-B9b6T9/RkJDkehMC5/MxqnkjxWj5LZg4jehAn6aeamE=";
  };
in {
  # 3. 链接主题文件
  xdg.configFile."yazi/flavors/catppuccin-mocha.yazi".source = "${catppuccin-flavor-src}/catppuccin-mocha.yazi";

  programs.yazi = {
    enable = true;
    # 这会自动在 .bashrc 中注入一个 `y` 函数
    # 使用 `y` 命令启动 yazi，退出时会自动 cd 到当前目录
    # 尝试过设置为true 但y函数没有被识别 改成false 然后手动注入y函数
    enableBashIntegration = false;

    # 4. 挂载插件
    plugins = {
      "full-border" = "${yazi-plugins-src}/full-border.yazi";
      "git" = "${yazi-plugins-src}/git.yazi";
      "smart-filter" = "${yazi-plugins-src}/smart-filter.yazi";
      "chmod" = "${yazi-plugins-src}/chmod.yazi";
    };

    # 5. Lua 初始化
    initLua = ''
      require("full-border"):setup {
          type = ui.Border.ROUNDED,
      }

      function Status:owner()
        local h = cx.active.current.hovered
        if h == nil or ya.target_family() ~= "unix" then
          return ui.Line {}
        end

        return ui.Line {
          ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
          ui.Span(":"),
          ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
          ui.Span(" "),
        }
      end

      Status:children_add(Status.owner, 500, Status.RIGHT)
    '';

    settings = {
      mgr = {
        ratio = [2 3 4];
        sort_by = "natural";
        sort_sensitive = false;
        sort_dir_first = true;
        linemode = "size";
        show_hidden = true;
        show_symlink = true;
        scrolloff = 5;
      };

      preview = {
        tab_size = 2;
        max_width = 1600;
        max_height = 1200;
        cache_dir = "";
        image_filter = "lanczos3";
        image_quality = 90;
      };

      opener = {
        edit = [
          {
            run = ''$${EDITOR:-nvim} "$@"'';
            block = true;
            for = "unix";
          }
        ];
      };

      open = {
        prepend_rules = [
          {
            name = "*/";
            use = ["edit"];
          }
          {
            mime = "text/*";
            use = "edit";
          }
          {
            name = "*.json";
            use = "edit";
          }
        ];
      };

      plugin = {
        prepend_fetchers = [
          {
            id = "git";
            name = "*";
            run = "git";
          }
          {
            id = "git";
            name = "*/";
            run = "git";
          }
        ];
      };

      theme = {
        flavor = {use = "catppuccin-mocha";};
      };
    };

    # 1. 使用 'mgr' 而非 'manager' 以匹配新版 Yazi 规范 (消除警告)
    # 2. 必须嵌套在 'prepend_keymap' 下，否则会生成错误的 TOML 结构 (消除 invalid type 报错)
    keymap = {
      mgr = {
        prepend_keymap = [
          {
            on = ["F"];
            run = "plugin smart-filter";
            desc = "Smart filter";
          }
          {
            on = ["c" "m"];
            run = "plugin chmod";
            desc = "Chmod";
          }
          {
            on = ["g" "s"];
            run = "plugin git";
            desc = "Git status";
          }
          {
            on = ["g" "d"];
            run = "cd ~/.config/yazi";
            desc = "Go to config";
          }
          {
            on = ["!"];
            run = ''shell "$SHELL" --block'';
            desc = "Open shell here";
          }
        ];
      };
    };
  };
}
