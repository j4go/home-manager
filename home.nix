# 用户状态声明和配置实现
{
  config,
  lib,
  pkgs,
  ...
}: let
  # --- 提取配置变量 ---
  proxy = config.myOptions.proxy;
  hasBat = config.programs.bat.enable;
  hasEza = config.programs.eza.enable;

  # 代理白名单
  noProxyList = ["localhost" "127.0.0.1" "::1" "192.168.0.0/16" "172.16.0.0/12" "10.0.0.0/8" "*.local" ".lan"];
  noProxyStr = builtins.concatStringsSep "," noProxyList;
in {
  imports = [
    ./nh.nix
    ./basic_tools.nix
    ./modules/import.nix
  ];

  # --- 自定义选项 ---
  options.myOptions = {
    proxy = {
      enable = lib.mkEnableOption "是否开启代理";
      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1:10808";
        description = "代理服务器地址 (IP:Port)";
      };
    };
  };

  config = {
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;

    # --- 全局环境变量 ---
    home.sessionVariables = {
      FLAKE = "${config.home.homeDirectory}/.config/home-manager";
      EDITOR = "nvim";
      VISUAL = "nvim";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      PYTHONPYCACHEPREFIX = "/tmp/python-cache";
      MANPAGER =
        if hasBat
        then "sh -c 'col -bx | ${lib.getExe pkgs.bat} -l man -p'"
        else "less";
      MANROFFOPT = "-c";
      NO_PROXY = noProxyStr;
      no_proxy = noProxyStr;
    };

    # --- 深度集成程序 (需配置参数的工具) ---
    # 除了安装软件包，Home Manager 还生成和管理对应的参数配置
    programs = {
      bat = {
        enable = true;
        config = {
          style = "numbers,changes,header";
        };
      };

      fd = {
        enable = true;
        hidden = true;
      }; # 替代了 basic_tools 中的 fd 包

      zoxide = {
        enable = true;
        enableBashIntegration = true;
        options = ["--cmd cd"];
      };

      eza = {
        enable = true;
        enableBashIntegration = true;
        git = true;
        extraOptions = ["--group-directories-first" "--header"];
      };

      fzf = {
        enable = true;
        enableBashIntegration = true;
        defaultCommand = "${lib.getExe pkgs.fd} --type f --strip-cwd-prefix --hidden --follow --exclude .git";
        defaultOptions = ["--height 40%" "--layout=reverse" "--border" "--inline-info" "--color='header:italic'"];
        fileWidgetCommand = "${lib.getExe pkgs.fd} --type f --strip-cwd-prefix --hidden --follow --exclude .git";
        fileWidgetOptions = ["--preview '[[ -d {} ]] && ${lib.getExe pkgs.eza} --tree --color=always --level=2 {} || ${lib.getExe pkgs.bat} --style=numbers --color=always --line-range=:500 {}'"];
      };
    };

    # --- 全局别名 ---
    home.shellAliases = lib.mkMerge [
      {
        # Editor & System
        v = "vim";
        vi = "nvim";
        sedit = "sudo -E systemctl edit";
        rga = "rg -uuL";
        grep = "grep --color=auto";
        su = "su -";
        "7z" = "7zz"; # 对应 basic_tools 中的 _7zz
        rm = "trash-put"; # 对应 basic_tools 中的 trash-cli
        h = "history";

        # Tools
        m = "tldr"; # 对应 programs.tealdeer
        lg = "lazygit";
        ping = "gping";
        dig = "doggo";
        print = "figlet";
        ya = "yazi"; # 需确认是否安装了 yazi，建议加入 basic_tools
        hm = "cd ~/.config/home-manager/";

        # Zellij
        ze = "zellij";
        zew = "zellij attach w -c";
        zels = "zellij list-sessions";

        # Fetch
        os = "fastfetch";
        neo = "fastfetch";
        fetch = "fastfetch";

        # Proxy
        setproxy = "export all_proxy=http://${proxy.address} http_proxy=http://${proxy.address} https_proxy=http://${proxy.address} no_proxy=${noProxyStr} NO_PROXY=${noProxyStr}";
        unproxy = "unset all_proxy http_proxy https_proxy no_proxy NO_PROXY";
      }
      (lib.mkIf hasEza {
        ls = "${lib.getExe pkgs.eza} --icons=auto --git";
        ll = "${lib.getExe pkgs.eza} -l -a --icons=auto --git --time-style=relative";
        la = "${lib.getExe pkgs.eza} -l -a --icons=auto --git --time-style=relative";
        lt = "${lib.getExe pkgs.eza} --tree --level=2 --icons=auto --git --ignore-glob='.git|node_modules'";
      })
      (lib.mkIf hasBat {
        man = "batman";
        bgrep = "batgrep";
        bdiff = "batdiff";
      })
    ];
  };
}
