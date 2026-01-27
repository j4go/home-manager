{ config, lib, pkgs, hostName, ... }:
let
  cfg = config.myOptions.shell.bash;
  proxy = config.myOptions.proxy;
in {
  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoreboth" ];
      historyFileSize = 20000;
      historySize = 10000;
      shellOptions = [ "histappend" "checkwinsize" "cdspell" ];
      
      sessionVariables = {
        EDITOR = "nvim";
        LANG = "en_US.UTF-8";
      };

      shellAliases = {
        ll = "ls -alF";
        la = "ls -A";
        l = "ls -CF";
        grep = "grep --color=auto";
        ls = "ls --color=auto";
      };

      initExtra = ''
        # --- 代理配置 (由 Nix 声明式注入) ---
        ${if proxy.enable then ''
          export http_proxy="http://${proxy.address}"
          export https_proxy="http://${proxy.address}"
          export ftp_proxy="http://${proxy.address}"
          export rsync_proxy="http://${proxy.address}"
          export no_proxy="localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,*.local,*.internal"
          export NO_PROXY="$no_proxy"
        '' else "# 此主机未开启代理"}

        # --- 系统基础配置继承 ---
        [ -f /etc/bashrc ] && . /etc/bashrc
        [ -f /etc/bash.bashrc ] && . /etc/bash.bashrc

        # --- 动态别名 ---
        command -v fastfetch >/dev/null && alias neo='fastfetch'
        command -v trash-put >/dev/null && alias rm='trash-put'

        # --- 快速部署函数 (Fast Deployment) ---
        hm-save() {
          (
            cd ~/.config/home-manager || return
            git add .
            
            FLAKE_NAME="${hostName}" 

            echo -e "🔍 [Target: $FLAKE_NAME] 正在执行预构建检查..."
            
            # 使用 nix run 替代 nix build + home-manager switch，更简洁
            if home-manager switch --flake ".#$FLAKE_NAME" -b backup; then
                echo -e "🎉 成功！正在提交记录..."
                git commit -m "Update from $FLAKE_NAME: $(date '+%Y-%m-%d %H:%M:%S')"
            else
                echo -e "💥 部署失败！"
            fi
          )
        }
        
        # --- 维护函数 ---
        hm-update() {
          (
            cd ~/.config/home-manager || return
            
            echo -e "🌐 正在更新 Flake 依赖 (可能需要联网)..."
            nix flake update
            
            echo -e "🧹 正在执行例行磁盘维护 (清理 10 天前的旧版本)..."
            # 增加 --json 选项，让输出更友好
            nix-collect-garbage --delete-older-than 10d --json
            
            echo -e "✨ 维护完成。"
          )
        }
      '';
    };
  };
}
