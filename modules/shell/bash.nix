{ config, lib, pkgs, inputs, system, hostName, ... }:
let
  proxy = config.myOptions.proxy;
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};

  # 1. 🎨 FZF 基础 UI 配置（不含全局预览，防止干扰 Ctrl-R）
  fzfConfig = [
    "--height 40%"
    "--layout=reverse"
    "--border"
    "--inline-info"
    "--color='header:italic'"
    "--bind 'ctrl-/:toggle-preview'"
  ];
  fzfConfigStr = builtins.concatStringsSep " " fzfConfig;

  # 2. 🔍 FZF 搜索后端命令
  fzfCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";

  # 3. 🧠 智能预览逻辑 (Smart Preview Script)
  # 判断是目录则显示 tree，是文件则显示 bat，否则不显示
  smartPreview = ''
    if [ -d {} ]; then
      eza --tree --color=always --icons=auto --level=2 {}
    elif [ -f {} ]; then
      bat --style=numbers --color=always --line-range=:500 {}
    else
      echo "No preview available"
    fi
  '';

in {
  config = {
    programs = {
      zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        options = [ "--cmd cd" ]; 
      };
      eza = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        git = true;
        extraOptions = [ "--group-directories-first" "--header" ];
      };
      fzf = {
        enable = true; 
        enableBashIntegration = true;
        enableZshIntegration = true;
        # 仅注入基础 UI 配置
        defaultOptions = fzfConfig;
      };
      pay-respects = {
        enable = true;
        enableBashIntegration = false;
        enableZshIntegration = true;
      };
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;

      historySize = 1000000;
      historyFileSize = 1000000;
      historyControl = [ "ignoreboth" "erasedups" ];

      shellOptions = [ "histappend" "checkwinsize" "globstar" "cdspell" "dirspell" ];

      sessionVariables = {
        EDITOR = "nvim";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        PYTHONPYCACHEPREFIX = "/tmp/python-cache";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
      };

      shellAliases = {
        ls = "eza --icons=auto --git";
        ll = "eza -l -a --icons=auto --git --time-style=relative";
        la = "ll";
        lt = "eza --tree --level=2 --icons=auto --git --ignore-glob='.git|node_modules'";
        cat   = "bat";
        man   = "batman";
        bgrep = "batgrep";
        bdiff = "batdiff";
        "7z" = "7zz";
        grep = "grep --color=auto";
        gitup = "git add . && git commit -m 'update: $(date +%Y-%m-%d)' && git push";
        rm = "trash-put";
        h = "history";
        so = "source ~/.bashrc";
        f = "pay-respects";
        setproxy = "export all_proxy=http://${proxy.address} http_proxy=http://${proxy.address} https_proxy=http://${proxy.address}";
        unproxy = "unset all_proxy http_proxy https_proxy";
        hm = "cd ~/.config/home-manager/";
        os = "fastfetch";
        neo = "fastfetch";
        fetch = "fastfetch";
        neofetch = "fastfetch";
      };

      initExtra = ''
        # --- FZF 环境变量注入 (针对交互式 Shell 优化) ---
        # 1. 全局基础配置
        export FZF_DEFAULT_OPTS="${fzfConfigStr}"
        export FZF_DEFAULT_COMMAND="${fzfCommand}"

        # 2. 🚀 文件搜索 (Ctrl-T): 开启智能预览
        export FZF_CTRL_T_OPTS="--preview '${smartPreview}'"
        export FZF_CTRL_T_COMMAND="${fzfCommand}"

        # 3. 🚀 目录搜索 (Alt-C): 开启树状结构预览
        export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons=auto --level=2 {}'"

        # 4. 🚀 历史记录 (Ctrl-R): 强制隐藏预览窗口，防止报错并保持界面清爽
        export FZF_CTRL_R_OPTS="--preview-window hidden"

        # --- 其他原有配置 ---
        export PROMPT_COMMAND="history -a; history -n"

        ${if proxy.enable then ''
          export http_proxy="http://${proxy.address}"
          export https_proxy="http://${proxy.address}"
          export all_proxy="http://${proxy.address}"
          export no_proxy="localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,*.local,*.internal"
        '' else "# Proxy disabled"}

        mamba_setup() {
            local mamba_path="''${HOME}/.nix-profile/etc/profile.d"
            if [[ -f "$mamba_path/conda.sh" ]]; then
                source "$mamba_path/conda.sh"
                source "$mamba_path/mamba.sh"
            fi
            unalias mamba conda 2>/dev/null
            unfunction mamba_setup 2>/dev/null
        }
        alias mamba='mamba_setup; mamba'
        alias conda='mamba_setup; conda'

        edit() {
            for file in "$@"; do
                [[ ! -e "$file" ]] && touch "$file" && echo "📄 Created: $file"
            done
            $EDITOR "$@"
        }

        hm-save() {
        (
          cd ~/.config/home-manager || return
          git add .
          FLAKE_NAME="${hostName}" 
          if home-manager switch --flake ".#$FLAKE_NAME" -b backup; then
              echo -e "🎉 Switch Successful!"
              [[ $(git diff --cached) ]] && git commit -m "Update from $FLAKE_NAME: $(date '+%Y-%m-%d %H:%M:%S')" || echo "ℹ️ No changes."
          else
              return 1
          fi
        )}

        hm-fix() {
          (
            cd ~/.config/home-manager || return
            nix flake update && nix-collect-garbage --delete-older-than 10d 
          )
        }
      '';
    };
  };
}
