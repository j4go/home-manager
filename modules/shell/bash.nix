{ config, lib, pkgs, hostName, ... }:
let
  # 变量引用，以便在 initExtra 中使用代理逻辑
  proxy = config.myOptions.proxy;
in {
  config = {
    
    # ========================================================================
    # 🛠️ 现代 Shell 工具套件 (Modern Tool Suite)
    # ========================================================================
    programs = {
      eza = {
        enable = true;
        enableBashIntegration = true;
        icons = "auto";
        git = true;
      };
      
      zoxide = {
        enable = true;
        enableBashIntegration = true;
      };

      fzf = {
        enable = true;
        enableBashIntegration = true;
      };
    };

    # ========================================================================
    # 🐚 Bash 核心配置
    # ========================================================================
    programs.bash = {
      enable = true;
      enableCompletion = true;

      # --- 历史记录控制 ---
      historySize = 100000;
      historyFileSize = 200000;
      historyControl = [ "ignoreboth" "erasedups" ];

      # --- Shell 选项 ---
      shellOptions = [ 
        "histappend"
        "checkwinsize"
        "globstar"
        "cdspell"
        "dirspell" 
      ];

      sessionVariables = {
        EDITOR = "nvim";
        LANG = "en_US.UTF-8";
      };

      # --- 别名系统 ---
      shellAliases = {
        "7z" = "7zz";
        l = "eza -lh --icons=auto"; 
        ll = "eza -lha --icons=auto --sort=name --group-directories-first";
        la = "eza -a --icons=auto";
        lt = "eza --tree --level=2 --icons=auto";
        grep = "grep --color=auto";
        gitup = "git add . && git commit -m 'update: $(date +%Y-%m-%d)' && git push";
        rm = "trash-put"; 
      };

      # --- 初始化脚本 (针对 GNOME 终端标题优化) ---
      initExtra = ''
        # ---------------------------------------------------------------------
        # 🤫 终端标题静默处理 (Fix GNOME Terminal Title)
        # ---------------------------------------------------------------------
        # 1. 重置 PROMPT_COMMAND：仅保留历史同步，移除系统默认的标题更新序列
        export PROMPT_COMMAND="history -a; history -n"

        # 2. 设置一次性静态标题：防止标题栏显示正在运行的命令
        echo -ne "\033]0;Terminal\033\\"

        # ---------------------------------------------------------------------
        # 🌐 代理配置 (声明式注入)
        # ---------------------------------------------------------------------
        ${if proxy.enable then ''
          export http_proxy="http://${proxy.address}"
          export https_proxy="http://${proxy.address}"
          export all_proxy="http://${proxy.address}"
          export no_proxy="localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,*.local,*.internal"
        '' else "# Proxy disabled"}

        # ---------------------------------------------------------------------
        # 🚀 实用函数 (Functions)
        # ---------------------------------------------------------------------
        edit() {
            for file in "$@"; do
                if [ ! -e "$file" ]; then
                    touch "$file"
                    echo "📄 Created: $file"
                fi
            done
            $EDITOR "$@"
        }

        hm-save() {
        (
          cd ~/.config/home-manager || return
          git add .
          FLAKE_NAME="${hostName}" 
          echo -e "🔍 [Target: $FLAKE_NAME] Pre-check..."
          
          if home-manager switch --flake ".#$FLAKE_NAME" -b backup; then
              echo -e "🎉 Switch Successful!"
              if ! git diff --cached --quiet; then
                  echo -e "💾 Committing changes..."
                  git commit -m "Update from $FLAKE_NAME: $(date '+%Y-%m-%d %H:%M:%S')"
              else
                  echo -e "ℹ️ No changes to commit."
              fi
          else
              echo -e "💥 Deployment Failed!"
              return 1
          fi
        )}

        hm-fix() {
          (
            cd ~/.config/home-manager || return
            echo -e "🌐 Updating Flake inputs..."
            nix flake update
            echo -e "🧹 Cleaning garbage (>10d)..."
            nix-collect-garbage --delete-older-than 10d 
            echo -e "✨ Maintenance done."
          )
        }
      '';
    };
  };
}
