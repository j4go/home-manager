#           _ __
#    ____ _(_) /_
#   / __ `/ / __/
#  / /_/ / / /_
#  \__, /_/\__/
# /____/
{
  config,
  lib,
  pkgs,
  ...
}: let
  proxy = config.myOptions.proxy;
in {
  # =================================================================
  # 1. Lazygit 配置
  # =================================================================
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        language = "en";
        timeFormat = "2006-01-02";
        shortTimeFormat = "15:04";
        showIcons = false;
        border = "rounded";
        nerdFontsVersion = "3";
      };
      git = {
        pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          }
        ];
      };
    };
  };

  # =================================================================
  # 2. Delta 配置
  # =================================================================
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "Dracula";
    };
  };

  # =================================================================
  # 3. Git 核心配置 (严格遵循 settings 格式)
  # =================================================================
  programs.git = {
    enable = true;

    # 启用 LFS 支持
    lfs.enable = true;

    settings = {
      # 用户身份
      user = {
        name = "j4go";
        email = "yianny@163.com";
      };

      # 核心行为
      core = {
        autocrlf = false;
        quotepath = false;
        ignorecase = false;
        conflictstyle = "zdiff3";
      };

      safe = {
        directory = "*";
      };

      # 初始化
      init = {
        defaultBranch = "main";
      };

      # 颜色
      color = {
        ui = true;
      };

      # 拉取与推送
      pull = {
        rebase = true;
      };
      push = {
        default = "current";
        followTags = true;
        autoSetupRemote = true;
      };

      # 获取与清理
      fetch = {
        prune = true;
      };

      # 辅助功能
      help = {
        autocorrect = "prompt";
      };

      # 别名系统 (Alias)
      alias = {
        st = "status";
        co = "checkout";
        ci = "commit";
        br = "branch";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        lg = "log --graph --pretty=format:'%C(bold yellow)%h%Creset %C(magenta)-%Creset %s %C(auto)%d%Creset %C(dim white)(%cr)%Creset %C(bold blue)<%an>%Creset' --abbrev-commit -n 20";
      };

      # 网络与缓冲区 (合并静态设置与动态代理)
      http =
        {
          sslVerify = false;
          postBuffer = 957286400;
        }
        // (lib.optionalAttrs proxy.enable {
          proxy = "http://${proxy.address}";
        });

      https = lib.mkIf proxy.enable {
        proxy = "http://${proxy.address}";
      };
    };
  };
}
