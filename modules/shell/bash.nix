{
  config,
  lib,
  pkgs,
  hostName,
  ...
}: let
  # --- 变量提取 ---
  proxy = config.myOptions.proxy;
  hasBat = config.programs.bat.enable;
  hasEza = config.programs.eza.enable;

  # 代理白名单配置
  noProxyList = ["localhost" "127.0.0.1" "::1" "192.168.0.0/16" "172.16.0.0/12" "10.0.0.0/8" "*.local" ".lan"];
  noProxyStr = builtins.concatStringsSep "," noProxyList;
in {
  config = {
    # --- 软件包管理 ---
    home.packages = with pkgs; [
      trash-cli
      fastfetch
      micromamba
      figlet
      toilet
      chafa
      lolcat
      fd
    ];

    # --- 声明式全局环境变量 ---
    # 业界标准：在 home.sessionVariables 定义，确保变量在全局环境生效
    home.sessionVariables = {
      EDITOR = "nvim";
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

    # --- 程序集成配置 ---
    programs = {
      # zoxide：自动接管 cd
      zoxide = {
        enable = true;
        enableBashIntegration = true;
        options = ["--cmd cd"];
      };

      # eza：现代化的 ls 替代品
      eza = {
        enable = true;
        enableBashIntegration = true;
        git = true;
        extraOptions = ["--group-directories-first" "--header"];
      };

      # fzf：模糊搜索集成
      fzf = {
        enable = true;
        enableBashIntegration = true;
        defaultCommand = "${lib.getExe pkgs.fd} --type f --strip-cwd-prefix --hidden --follow --exclude .git";
        defaultOptions = [
          "--height 40%"
          "--layout=reverse"
          "--border"
          "--inline-info"
          "--color='header:italic'"
          "--bind 'ctrl-/:toggle-preview'"
        ];
        fileWidgetCommand = "${lib.getExe pkgs.fd} --type f --strip-cwd-prefix --hidden --follow --exclude .git";
        fileWidgetOptions = [
          "--preview '[[ -d {} ]] && ${lib.getExe pkgs.eza} --tree --color=always --level=2 {} || ${lib.getExe pkgs.bat} --style=numbers --color=always --line-range=:500 {}'"
        ];
        changeDirWidgetCommand = "${lib.getExe pkgs.fd} --type d --strip-cwd-prefix --hidden --follow --exclude .git";
        changeDirWidgetOptions = ["--preview '${lib.getExe pkgs.eza} --tree --color=always --icons=auto --level=2 {}'"];
      };
    };

    # --- Bash 核心配置 ---
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historySize = 1000000;
      historyFileSize = 1000000;
      historyControl = ["ignoreboth" "erasedups"];
      shellOptions = ["histappend" "checkwinsize" "globstar" "cdspell" "dirspell" "checkjobs" "histverify"];

      # 保持 Alias
      shellAliases = lib.mkMerge [
        {
          os = "fastfetch";
          neo = "fastfetch";
          fetch = "fastfetch";
          su = "su -";
          "7z" = "7zz";
          so = "source ~/.bashrc";
          m = "tldr";
          grep = "grep --color=auto";
          rm = "trash-put";
          h = "history";
          lg = "lazygit";
          ping = "gping";
          dig = "doggo";
          print = "figlet";
          ze = "zellij";
          zew = "zellij attach w -c";
          zels = "zellij list-sessions";
          hm = "cd ~/.config/home-manager/";

          # 代理控制别名
          setproxy = "export all_proxy=http://${proxy.address} http_proxy=http://${proxy.address} https_proxy=http://${proxy.address} no_proxy=${noProxyStr} NO_PROXY=${noProxyStr}";
          unproxy = "unset all_proxy http_proxy https_proxy no_proxy NO_PROXY";

          # Git 快捷提交
          gitup = "git add . && git commit -m \"update: $(date +%Y-%m-%d)\" && git push";
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

      # 交互式 Shell 初始化
      initExtra = ''
        # 非交互式 Shell 提前返回
        [[ $- == *i* ]] || return

        # 实用函数
        mkcd() { mkdir -p "$1" && cd "$1"; }

        # Micromamba 懒加载
        micromamba() {
          local bin="${lib.getExe pkgs.micromamba}"
          if [ -f "$bin" ]; then
             eval "$($bin shell hook -s bash)"
             unset -f micromamba
             micromamba "$@"
          else
             echo "❌ Micromamba not found!"
          fi
        }
        alias mamba='micromamba'
        alias conda='micromamba'

        # HM 维护函数 (对齐 flake.nix 中的 alejandra)
        hm-save() {
          local msg="Update: $(date '+%Y-%m-%d %H:%M:%S')"
          if [ -n "$1" ]; then msg="Update: $1"; fi
          (
            cd ~/.config/home-manager || return
            if command -v nix >/dev/null; then
              nix fmt . &>/dev/null
            fi
            git add .
            if home-manager switch --flake ".#${hostName}" -b backup; then
              [[ -n $(git diff --cached) ]] && git commit -m "$msg" && echo "🎉 Successful!" || echo "ℹ️ No changes."
            else
              return 1
            fi
          )
        }

        # 历史同步
        _sync_history() { history -a; history -n; }
        if [[ ";$PROMPT_COMMAND;" != *";_sync_history;"* ]]; then
          PROMPT_COMMAND="_sync_history''${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
        fi

        # 代理注入
        ${lib.optionalString proxy.enable ''
          export http_proxy="http://${proxy.address}"
          export https_proxy="http://${proxy.address}"
          export all_proxy="http://${proxy.address}"
          echo "🌐 Proxy enabled: ${proxy.address}"
        ''}
      '';
    };
  };
}
