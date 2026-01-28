{ config, lib, pkgs, hostName, ... }:
let
  cfg = config.myOptions.shell.bash;
  proxy = config.myOptions.proxy;
in {
  config = lib.mkIf cfg.enable {
    
    # ========================================================================
    # 🛠️ 现代 Shell 工具套件 (Modern Tool Suite)
    # ========================================================================
    # 在开启 Bash 时，自动启用这些增强工具，无需在 packages.nix 手动管理
    programs = {
      # 替代 ls：提供图标、Git 状态、更好的排版
      eza = {
        enable = true;
        enableBashIntegration = true;
        icons = "auto";
        git = true;
      };
      
      # 替代 cd：智能目录跳转 (z dir)
      zoxide = {
        enable = true;
        enableBashIntegration = true;
      };

      # 替代 Ctrl+R：模糊历史搜索
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

      # --- 历史记录控制 (对标 Zsh) ---
      historySize = 100000;
      historyFileSize = 200000;
      # ignoreboth: 忽略空格开头的命令和重复命令
      # erasedups: 清除整个历史文件中的重复行 (更激进)
      historyControl = [ "ignoreboth" "erasedups" ];

      # --- Shell 选项 ---
      shellOptions = [ 
        "histappend"     # 追加历史而非覆盖
        "checkwinsize"   # 窗口大小改变时重绘
        "globstar"       # 开启 ** 递归匹配 (类似 Zsh)
        "cdspell"        # 路径拼写自动纠正
        "dirspell" 
      ];

      sessionVariables = {
        EDITOR = "nvim";
        LANG = "en_US.UTF-8";
      };

      # --- 别名系统 ---
      shellAliases = {
        # 基础命令增强 (利用 eza)
        l = "eza -lh --icons=auto"; 
        ll = "eza -lha --icons=auto --sort=name --group-directories-first";
        la = "eza -a --icons=auto";
        lt = "eza --tree --level=2 --icons=auto"; # 树状视图
        grep = "grep --color=auto";
        gitup = "git add . && git commit -m 'update: $(date +%Y-%m-%d)' && git push";
        
        # 安全删除 (安装 trash-cli)
        rm = "trash-put"; 
      };

      # --- 初始化脚本 (Init Extra) ---
      initExtra = ''
        # ---------------------------------------------------------------------
        # 🔄 历史记录实时同步 (History Sync)
        # ---------------------------------------------------------------------
        # 让 Bash 像 Zsh 一样，在一个窗口执行命令，另一个窗口立即能搜到。
        export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

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
        
        # 快速创建并编辑文件 (移植自你的 edit 函数)
        edit() {
            for file in "$@"; do
                if [ ! -e "$file" ]; then
                    touch "$file"
                    echo "📄 Created: $file"
                fi
            done
            $EDITOR "$@"
        }

        # Home Manager 快速部署 (带 Git 检查)
        hm-save() {
        (
          cd ~/.config/home-manager || return
          # 1. 暂存所有变更
          git add .
          FLAKE_NAME="${hostName}" 
          echo -e "🔍 [Target: $FLAKE_NAME] Pre-check..."
          
          # 2. 尝试构建并切换
          if home-manager switch --flake ".#$FLAKE_NAME" -b backup; then
              echo -e "🎉 Switch Successful!"
              
              # 3. 检查是否有实际变更需要提交
              if ! git diff --cached --quiet; then
                  echo -e "💾 Committing changes..."
                  git commit -m "Update from $FLAKE_NAME: $(date '+%Y-%m-%d %H:%M:%S')"
              else
                  echo -e "ℹ️ No changes to commit (clean working tree)."
              fi
          else
              echo -e "💥 Deployment Failed!"
              return 1
          fi
        )}

        # 系统维护
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
