{ pkgs, ... }: {
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
      EDITOR = "vim";
      LANG = "en_US.UTF-8";
    };

    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      grep = "grep --color=auto";
      ls = "ls --color=auto";
    };

    # ◆ 复杂逻辑与脚本
    initExtra = ''
      # --- 1. 系统基础配置继承 ---
      if [ -f /etc/bashrc ]; then . /etc/bashrc;
      elif [ -f /etc/bash.bashrc ]; then . /etc/bash.bashrc;
      fi

      # --- 2. 动态别名 ---
      command -v fastfetch >/dev/null && alias neo='fastfetch'
      command -v fastfetch >/dev/null && alias fetch='fastfetch'
      command -v trash-put >/dev/null && alias rm='trash-put'

      # --- 3. 跨平台包管理器适配 ---
      if command -v dnf >/dev/null; then
          alias sys-update='sudo dnf update'
          alias sys-clean='sudo dnf autoremove && sudo dnf clean all'
      elif command -v apt >/dev/null; then
          alias sys-update='sudo apt update && sudo apt upgrade'
          alias sys-clean='sudo apt autoremove && sudo apt clean'
      fi

      # --- 4. 全局路径去重 ---
      export PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: '!a[$1]++' | sed 's/:$//')

      # --- 5. 增强版 Home Manager 更新函数 ---
      hm-save() {
        (
          cd ~/.config/home-manager || return
          git add .
          
          # 1. 动态判断主机名
          FLAKE_NAME="rocky" # 默认值
          if [ "$(hostname)" = "rocky10" ]; then
            FLAKE_NAME="rocky10"
          fi
          if [ "$(hostname)" = "mint" ]; then
            FLAKE_NAME="mint"
          fi
          if [ "$(hostname)" = "fedora" ]; then
            FLAKE_NAME="fedora"
          fi

          echo -e "🔍 [Target: $FLAKE_NAME] 正在执行预构建检查 (Dry Run)..."
          
          # 🔴 核心修复：使用 Nix 原生构建命令
          # 直接指向 Flake 内部的具体输出路径，绝不出错
          if nix build ".#homeConfigurations.$FLAKE_NAME.activationPackage"; then
              echo -e "✅ 语法与构建检查通过！"
              
              # 清理构建产物 (nix build 会生成一个 result 软链接)
              [ -L result ] && unlink result
              
              echo -e "🚀 正在应用新配置 (Switch)..."
              
              # 2. 正式切换
              # 优先使用本地安装的 home-manager (速度快)
              if home-manager switch --flake ".#$FLAKE_NAME" -b backup; then
                  echo -e "🎉 配置应用成功！"
                  echo -e "💾 正在提交 Git 记录..."
                  git commit -m "Update from $(hostname): $(date '+%Y-%m-%d %H:%M:%S')"
              else
                  echo -e "❌ 切换失败 (Activation Failed)！请检查报错。"
              fi
          else
              echo -e "💥 构建失败 (Build Failed)！配置未应用。"
          fi
        )
      }
    '';
  };
}
