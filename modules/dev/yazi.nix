{pkgs, ...}: let
  yazi-plugins-src = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "88990a6";
    hash = "sha256-0K6qGgbGt8N6HgGNEmn2FDLar6hCPiPBbvOsrTjSubM=";
  };

  catppuccin-flavor-src = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "9e053d0";
    hash = "sha256-B9b6T9/RkJDkehMC5/MxqnkjxWj5LZg4jehAn6aeamE=";
  };
in {
  xdg.configFile."yazi/flavors/catppuccin-mocha.yazi".source = "${catppuccin-flavor-src}/catppuccin-mocha.yazi";

  programs.yazi = {
    enable = true;
    enableBashIntegration = false;

    plugins = {
      "full-border" = "${yazi-plugins-src}/full-border.yazi";
    };

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
        # 尝试改为 iterm2（Tabby 对此支持较好）或直接禁用
        # 如果报错持续，尝试将下行设为 "ueberzug" 或 "noop"
        preview_protocol = "iterm2";
      };

      opener = {
        edit = [
          {
            run = ''nvim "$@"'';
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

      theme = {
        flavor = {use = "catppuccin-mocha";};
      };
    };
  };
}
