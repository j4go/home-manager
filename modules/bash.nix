{pkgs, ...}: {
  programs.bash = {
    enable = true;
    enableCompletion = true; 
    historyControl = [ "ignoreboth" ];
    historyFileSize = 20000;
    historySize = 10000;
    shellOptions = [
      "histappend"
      "checkwinsize"
      "cdspell"
    ];
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
    # 复杂逻辑与脚本
    initExtra = ''
      # --- 动态代理配置 (基于主机名) ---
      # 💡 最佳实践：使用 case 语句处理多匹配，并添加 no_proxy
      case "$(hostname)" in
        "rocky" | "mint")
          export PROXY_URL="http://10.255.126.1:10808"
          ;;
        "fedora" | "rocky10")
          export PROXY_URL="http://192.168.3.248:10808"
          ;;
        *)
          export PROXY_URL=""
          ;;
      esac

      if [ -n "$PROXY_URL" ]; then
        export http_proxy="$PROXY_URL"
        export https_proxy="$PROXY_URL"
        export ftp_proxy="$PROXY_URL"
        export rsync_proxy="$PROXY_URL"
        # 🔴 重要：防止本地流量走代理导致连接失败
        export no_proxy="localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,*.local,*.internal"
        export NO_PROXY="$no_proxy"
      fi

      # --- 系统基础配置继承 ---
      if [ -f /etc/bashrc ]; then . /etc/bashrc;
      elif [ -f /etc/bash.bashrc ]; then . /etc/bash.bashrc;
      fi

      # --- 动态别名 ---
      command -v fastfetch >/dev/null && alias neo='fastfetch'
      command -v fastfetch >/dev/null && alias fetch='fastfetch'
      command -v trash-put >/dev/null && alias rm='trash-put'

      # --- 跨平台包管理器适配 ---
      if command -v dnf >/dev/null; then
          alias sys-update='sudo dnf update'
          alias sys-clean='sudo dnf autoremove && sudo dnf clean all'
      elif command -v apt >/dev/null; then
          alias sys-update='sudo apt update && sudo apt upgrade'
          alias sys-clean='sudo apt autoremove && sudo apt clean'
      fi

      # --- 全局路径去重 ---
      export PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: '!a[$1]++' | sed 's/:$//')

      # --- 增强版 Home Manager 更新函数 ---
      hm-save() {
        (
          cd ~/.config/home-manager || return
          git add .
          
          # 1. 动态判断主机名
          FLAKE_NAME="rocky" 
          if [ "$(hostname)" = "rocky10" ]; then FLAKE_NAME="rocky10"; fi
          if [ "$(hostname)" = "mint" ]; then FLAKE_NAME="mint"; fi
          if [ "$(hostname)" = "fedora" ]; then FLAKE_NAME="fedora"; fi

          echo -e "🔍 [Target: $FLAKE_NAME] 正在执行预构建检查 (Dry Run)..."
          
          if nix build ".#homeConfigurations.$FLAKE_NAME.activationPackage"; then
              echo -e "✅ 语法与构建检查通过！"
              [ -L result ] && unlink result
              echo -e "🚀 正在应用新配置 (Switch)..."
              
              if home-manager switch --flake ".#$FLAKE_NAME" -b backup; then
                  echo -e "🎉 配置应用成功！"
                  echo -e "💾 正在提交 Git 记录..."
                  git commit -m "Update from $(hostname): $(date '+%Y-%m-%d %H:%M:%S')"
              else
                  echo -e "❌ 切换失败！"
              fi
          else
              echo -e "💥 构建失败！"
          fi
        )
      }
    '';
  };
}
