{pkgs, vars, ...}: {
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
      # --- 代理配置 (由 Nix 在构建时注入) ---
      ${if vars.proxyUrl != "" then ''
        export http_proxy="${vars.proxyUrl}"
        export https_proxy="${vars.proxyUrl}"
        export ftp_proxy="${vars.proxyUrl}"
        export rsync_proxy="${vars.proxyUrl}"
        export no_proxy="${vars.noProxy}"
        export NO_PROXY="$no_proxy"
      '' else "# 此主机未配置代理"}

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
          echo "🧹 正在执行例行磁盘维护 (清理 10 天前的旧版本)..."
          nix-collect-garbage --delete-older-than 10d
        )
      }
    '';
  };
}
