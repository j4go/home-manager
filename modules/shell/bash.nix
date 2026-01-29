{ config, lib, pkgs, inputs, system, hostName, ... }:
let
  proxy = config.myOptions.proxy;
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};

  # fzf业界标准：将 UI 参数提取为独立变量，确保一致性
  fzfConfig = [
    "--height 40%"
    "--layout=reverse"
    "--border"
    "--inline-info" # 紧凑型显示匹配数
    "--color='header:italic'" # 样式微调
    "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    "--bind 'ctrl-/:toggle-preview'" # 专家技巧：按下 Ctrl-/ 可以隐藏/显示预览窗
  ];
  fzfConfigStr = builtins.concatStringsSep " " fzfConfig;

  # FZF 搜索命令
  fzfCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";

in {
  config = {
    programs = {
      # modern cd command:z (type z is a function)
      zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        # 进阶选项：用 zoxide 替换 cd 命令 (可选)
        # 这会让 cd 命令拥有 z 的智能跳转能力，同时保留 cd 的基础功能
        options = [ "--cmd cd" ]; 
      };
      # modern ls
      eza = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        git = true;
        # 利用 extraOptions 设置全局默认值，减少 alias 的长度
        extraOptions = [
          "--group-directories-first"
          "--header"
        ];
      };
      fzf = {
        enable = true; # 自动绑定 Ctrl-R, Ctrl-T, Alt-C
        enableBashIntegration = true;
        enableZshIntegration = true;
        defaultOptions = fzfConfig;
      };
      # modern thefuck
      pay-respects = {
        enable = true;
        enableBashIntegration = false;
        enableZshIntegration = true;
      };
    };

    # home.sessionVariables = {
    #   # 使用 lib.mkForce 强制覆盖 Home Manager 默认生成的变量
    #   FZF_DEFAULT_OPTS = lib.mkForce "${fzfConfigStr}";

    #   # 使用 fd 替代 find，并包含隐藏文件
    #   FZF_DEFAULT_COMMAND = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    #   FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
    # };

    programs.bash = {
      enable = true;
      enableCompletion = true;

      historySize = 1000000;
      historyFileSize = 1000000;
      historyControl = [ "ignoreboth" "erasedups" ];

      shellOptions = [ 
        "histappend" "checkwinsize" "globstar" "cdspell" "dirspell" 
      ];

      sessionVariables = {
        EDITOR = "nvim";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        PYTHONPYCACHEPREFIX = "/tmp/python-cache";
        
        # 让系统默认的 man 手册使用 bat 进行渲染
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
      };

      shellAliases = {
        # eza modern ls
        # 保持网格视图，适合快速浏览
        ls = "eza --icons=auto --git";
        # 详细列表，带相对时间，显示隐藏文件
        ll = "eza -l -a --icons=auto --git --time-style=relative";
        la = "ll";
        # 树状视图，忽略 .git 和 node_modules (防止刷屏)
        lt = "eza --tree --level=2 --icons=auto --git --ignore-glob='.git|node_modules'";

        # Bat 现代化替代方案
        cat   = "bat";
        man   = "batman";      # 需要 bat-extras.batman
        bgrep = "batgrep";     # 需要 bat-extras.batgrep
        bdiff = "batdiff";     # 需要 bat-extras.batdiff

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
        # fzf vars
        export FZF_DEFAULT_OPTS="${fzfConfigStr}"
        export FZF_DEFAULT_COMMAND="${fzfCommand}"
        export FZF_CTRL_T_COMMAND="${fzfCommand}"

        # sync history
        export PROMPT_COMMAND="history -a; history -n"

        # proxy
        ${if proxy.enable then ''
          export http_proxy="http://${proxy.address}"
          export https_proxy="http://${proxy.address}"
          export all_proxy="http://${proxy.address}"
          export no_proxy="localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,*.local,*.internal"
        '' else "# Proxy disabled"}

        # Mamba 延迟加载
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
