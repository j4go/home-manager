{
  config,
  lib,
  pkgs,
  inputs,
  system,
  hostName,
  ...
}: let
  proxy = config.myOptions.proxy;

  # 1. 代理配置增强
  noProxyList = [
    "localhost"
    "127.0.0.1"
    "::1"
    "192.168.0.0/16"
    "172.16.0.0/12"
    "10.0.0.0/8"
    "*.local"
    ".lan"
    ".sun"
  ];
  noProxyStr = builtins.concatStringsSep "," noProxyList;

  # 2. FZF 预览逻辑定义
  fzfConfig = [
    "--height 40%"
    "--layout=reverse"
    "--border"
    "--inline-info"
    "--color='header:italic'"
    "--bind 'ctrl-/:toggle-preview'"
  ];
  fzfCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
  smartPreview = "[[ -d {} ]] && eza --tree --color=always --icons=auto --level=2 {} || [[ -f {} ]] && bat --style=numbers --color=always --line-range=:500 {} || echo No-preview-available";
in {
  config = {
    programs = {
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
      # 3. FZF 原生配置优化
      fzf = {
        enable = true;
        enableBashIntegration = true;
        defaultOptions = fzfConfig;
        defaultCommand = fzfCommand;
        fileWidgetCommand = fzfCommand;
        fileWidgetOptions = [ "--preview '${smartPreview}'" ];
        changeDirWidgetCommand = "fd --type d --strip-cwd-prefix --hidden --follow --exclude .git";
        changeDirWidgetOptions = [ "--preview 'eza --tree --color=always --icons=auto --level=2 {}'" ];
      };
      pay-respects = {
        enable = true;
        enableBashIntegration = true;
      };
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;
      historySize = 1000000;
      historyFileSize = 1000000;
      historyControl = ["ignoreboth" "erasedups"];
      # 增加 checkjobs 确保退出时提醒未完成任务
      shellOptions = ["histappend" "checkwinsize" "globstar" "cdspell" "dirspell" "checkjobs"];

      sessionVariables = {
        EDITOR = "nvim";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        PYTHONPYCACHEPREFIX = "/tmp/python-cache";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
        # 注入 NO_PROXY
        NO_PROXY = noProxyStr;
        no_proxy = noProxyStr;
      };

      shellAliases = {
        # --- 基础增强 ---
        su = "su -";
        "7z" = "7zz";
        so = "source ~/.bashrc";
        ls = "eza --icons=auto --git";
        ll = "eza -l -a --icons=auto --git --time-style=relative";
        la = "ll";
        lt = "eza --tree --level=2 --icons=auto --git --ignore-glob='.git|node_modules'";
        
        # --- 工具替代 ---
        m = "tldr";
        cat = "bat --style=plain";
        man = "batman";
        bgrep = "batgrep";
        bdiff = "batdiff";
        grep = "grep --color=auto";
        rm = "trash-put";
        h = "history";
        lg = "lazygit";
        f = "pay-respects";
        os = "fastfetch";
        ping = "gping";
        dig = "doggo";
        
        # --- 代理管理 ---
        setproxy = "export all_proxy=http://${proxy.address} http_proxy=http://${proxy.address} https_proxy=http://${proxy.address} no_proxy=${noProxyStr} NO_PROXY=${noProxyStr}";
        unproxy = "unset all_proxy http_proxy https_proxy no_proxy NO_PROXY";
        
        # --- Nix 相关 ---
        hm = "cd ~/.config/home-manager/";
        gitup = "git add . && git commit -m \"update: $(date +%Y-%m-%d)\" && git push";
      };

      initExtra = ''
        # 4. 交互式 Shell 体验增强
        # 输入历史命令号后不立即执行，而是允许编辑
        shopt -s histverify
        # 实时同步多终端历史
        export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

        # 5. 代理自动注入
        ${lib.optionalString proxy.enable ''
          export http_proxy="http://${proxy.address}"
          export https_proxy="http://${proxy.address}"
          export all_proxy="http://${proxy.address}"
        ''}

        # 6. 懒加载函数优化
        mamba_setup() {
          local mamba_path="''${HOME}/.nix-profile/etc/profile.d"
          if [[ -f "$mamba_path/conda.sh" ]]; then
            source "$mamba_path/conda.sh"
            source "$mamba_path/mamba.sh"
          fi
          unalias mamba conda 2>/dev/null
        }
        alias mamba='mamba_setup; mamba'
        alias conda='mamba_setup; conda'

        # 7. 功能性函数 (业界标配)
        # 快速创建并进入目录
        mkcd() { mkdir -p "$1" && cd "$1"; }

        # 智能文件编辑
        edit() {
          for file in "$@"; do
            [[ ! -e "$file" ]] && touch "$file" && echo "📄 Created: $file"
          done
          $EDITOR "$@"
        }

        # Home-Manager 维护工作流
        hm-save() {
          (
            cd ~/.config/home-manager || return
            git add .
            echo -e "🧹 Running nix fmt..."
            nix fmt . || { echo "❌ Format failed"; return 1; }
            git add .
            if home-manager switch --flake ".#${hostName}" -b backup; then
              echo -e "🎉 Switch Successful!"
              [[ $(git diff --cached) ]] && git commit -m "Update: $(date '+%Y-%m-%d %H:%M:%S')" || echo "ℹ️ No changes."
            else
              return 1
            fi
          )
        }
      '';
    };
  };
}
