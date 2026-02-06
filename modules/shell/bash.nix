#     __               __
#    / /_  ____ ______/ /_
#   / __ \/ __ `/ ___/ __ \
#  / /_/ / /_/ (__  ) / / /
# /_.___/\__,_/____/_/ /_/
#
{
  config,
  lib,
  pkgs,
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
    ];

    # --- 声明式全局环境变量 ---
    home.sessionVariables = {
      # 使用动态路径
      FLAKE = "${config.home.homeDirectory}/.config/home-manager";
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
      fd = {
        enable = true;
        # hidden = true; # 是否搜索隐藏文件 注释是不搜索，不注释是搜索隐藏文件
      };

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

    # --- Bash核心配置 ---
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historySize = 1000000;
      historyFileSize = 1000000;
      historyControl = ["ignoreboth" "erasedups"];
      shellOptions = ["histappend" "checkwinsize" "globstar" "cdspell" "dirspell" "checkjobs" "histverify"];

      shellAliases = lib.mkMerge [
        {
          so = "source ~/.bashrc"; # 注意：HM 环境下这通常只重载 alias，不重载 env
          os = "macchina";
          neo = "fastfetch";
          fetch = "fastfetch";
          su = "su -";
          "7z" = "7zz";
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

          # Git
          gitls = "git ls-remote origin -h refs/heads/main";
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
        [[ $- == *i* ]] || return

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

        # HM 维护函数
        hm-save() {
          local flake_path="$FLAKE"
          local msg="Update: $(date '+%Y-%m-%d %H:%M:%S')"
          if [ -n "$1" ]; then msg="Update: $1"; fi

          nix fmt "$flake_path" &>/dev/null
          git -C "$flake_path" add .

          if nh home switch "$flake_path"; then
            if [[ -n $(git -C "$flake_path" diff --cached) ]]; then
              git -C "$flake_path" commit -m "$msg"
              echo "✅ 配置已成功应用并提交"
            else
              echo "ℹ 没有任何配置变更"
            fi
          else
            echo "❌ 构建终止：请检查上述错误日志"
            return 1
          fi
        }

        # 历史同步
        # 通常 history -a (追加内存到磁盘) 即可满足“不丢失”的需求。
        # history -n (从磁盘读到内存) 建议手动执行或仅在新开终端时读取。
        # 建议：如果你没有感觉到卡顿，保持现状即可。如果觉得 Prompt 反应慢，删掉 ; history -n。
        # _sync_history() { history -a; history -n; }
        _sync_history() { history -a; }
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

        # yazi y function
        function y() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
          yazi "$@" --cwd-file="$tmp"
          if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
              builtin cd -- "$cwd"
          fi
          \rm -f -- "$tmp"
        }
      '';
    };
  };
}
