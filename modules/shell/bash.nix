{
  config,
  lib,
  pkgs,
  hostName,
  ...
}: let
  # --- 变量提取与逻辑判断 ---
  proxy = config.myOptions.proxy;

  # 感知其他模块状态：用于动态生成别名和变量
  hasBat = config.programs.bat.enable;
  hasEza = config.programs.eza.enable;

  # 网络代理白名单：避免本地与私有流量走代理
  noProxyList = [
    "localhost"
    "127.0.0.1"
    "::1"
    "192.168.0.0/16"
    "172.16.0.0/12"
    "10.0.0.0/8"
    "*.local"
    ".lan"
  ];
  noProxyStr = builtins.concatStringsSep "," noProxyList;

  # FZF 核心预览逻辑：目录使用 eza，文件使用 bat
  fzfPreviewDir = "eza --tree --color=always --icons=auto --level=2 {}";
  fzfPreviewFile = "bat --style=numbers --color=always --line-range=:500 {}";
  smartPreview = "[[ -d {} ]] && ${fzfPreviewDir} || [[ -f {} ]] && ${fzfPreviewFile} || echo No-preview-available";
in {
  config = {
    # --- 软件包安装 ---
    home.packages = with pkgs; [
      trash-cli # 支撑 rm 别名
      fastfetch # 支撑 os/neo/fetch 别名
      micromamba # 支撑 Python 环境管理与懒加载逻辑
      # --- 终端视觉输出增强 ---
      figlet # 经典 ASCII 艺术字生成器
      toilet # FIGlet 的增强版，支持彩色输出
      chafa # 现代终端图形预览器
      lolcat # 为任何文本输出添加彩虹渐变效果
    ];

    # --- 终端增强程序 (插件系统) ---
    programs = {
      # 智能路径跳转
      zoxide = {
        enable = true;
        enableBashIntegration = true;
        options = ["--cmd cd"];
      };

      # 现代文件列表工具
      eza = {
        enable = true;
        enableBashIntegration = true;
        git = true;
        extraOptions = ["--group-directories-first" "--header"];
      };

      # 模糊搜索神器：原生集成配置
      fzf = {
        enable = true;
        enableBashIntegration = true;
        defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
        defaultOptions = [
          "--height 40%"
          "--layout=reverse"
          "--border"
          "--inline-info"
          "--color='header:italic'"
          "--bind 'ctrl-/:toggle-preview'"
        ];
        fileWidgetCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
        fileWidgetOptions = ["--preview '${smartPreview}'"];
        changeDirWidgetCommand = "fd --type d --strip-cwd-prefix --hidden --follow --exclude .git";
        changeDirWidgetOptions = ["--preview '${fzfPreviewDir}'"];
      };
    };

    # --- Bash 核心配置 ---
    programs.bash = {
      enable = true;
      enableCompletion = true;

      # 历史记录管理
      historySize = 1000000;
      historyFileSize = 1000000;
      historyControl = ["ignoreboth" "erasedups"];

      # Shell 行为微调：自动更正路径拼写、检查窗口大小、并发作业检查
      shellOptions = [
        "histappend" # 退出时追加历史而非覆盖
        "checkwinsize" # 每次命令后检查窗口大小
        "globstar" # 递归匹配 **/*
        "cdspell" # 自动纠正 cd 拼写
        "dirspell" # 自动纠正目录名拼写
        "checkjobs" # 退出前告知挂起的作业
        "histverify" # 执行历史扩展（!!）前先预览
      ];

      # 全局环境变量
      sessionVariables = {
        EDITOR = "nvim";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        PYTHONPYCACHEPREFIX = "/tmp/python-cache";
        # 动态 MANPAGER：若开启 bat 则使用高亮 man
        MANPAGER =
          if hasBat
          then "sh -c 'col -bx | bat -l man -p'"
          else "less";
        MANROFFOPT = "-c";
        NO_PROXY = noProxyStr;
        no_proxy = noProxyStr;
      };

      # 别名系统：基于模块感知进行分类管理
      shellAliases = lib.mkMerge [
        # 基础通用别名
        {
          os = "fastfetch";
          neo = "fastfetch";
          fetch = "fastfetch";
          su = "su -";
          "7z" = "7zz";
          so = "source ~/.bashrc";
          m = "tldr";
          grep = "grep --color=auto";
          rm = "trash-put";
          h = "history";
          lg = "lazygit";
          ping = "gping";
          dig = "doggo";
          print = "figlet";

          # Zellij 常用会话管理
          ze = "zellij";
          zew = "zellij attach w -c";
          zels = "zellij list-sessions";

          # 代理手动控制
          setproxy = "export all_proxy=http://${proxy.address} http_proxy=http://${proxy.address} https_proxy=http://${proxy.address} no_proxy=${noProxyStr} NO_PROXY=${noProxyStr}";
          unproxy = "unset all_proxy http_proxy https_proxy no_proxy NO_PROXY";

          # Nix/Home-Manager 工作流
          hm = "cd ~/.config/home-manager/";
          gitup = "git add . && git commit -m \"update: $(date +%Y-%m-%d)\" && git push";
        }

        # Eza 增强别名 (仅当启用 eza 时生效)
        (lib.mkIf hasEza {
          ls = "eza --icons=auto --git";
          ll = "eza -l -a --icons=auto --git --time-style=relative";
          la = "eza -l -a --icons=auto --git --time-style=relative";
          lt = "eza --tree --level=2 --icons=auto --git --ignore-glob='.git|node_modules'";
        })

        # Bat 增强别名 (仅当启用 bat 时生效)
        (lib.mkIf hasBat {
          man = "batman";
          bgrep = "batgrep";
          bdiff = "batdiff";
        })
      ];

      # --- [NIX BOOTSTRAP] ---
      # ⚠️ 关键修正：将 Nix 环境加载放在 bashrcExtra，确保其在 Alias 之前加载。
      # 解决 Non-login Shell（普通终端窗口）启动时不加载 Nix PATH 的问题。
      bashrcExtra = ''
        # 1. 🚀 [ROCKY/FEDORA 必备] 引入系统全局 Bash 配置
        # 缺少这段代码会导致 Non-login Shell 在某些环境下加载行为异常
        if [ -f /etc/bashrc ]; then
          . /etc/bashrc
        fi

        # 2. 🚀 [NIX 核心] 强制在文件最开头加载 Nix 环境
        if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
          . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        fi

        # 3. 🚀 [USER PROFILE] 确保用户安装的包路径生效
        if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi
      '';

      # --- [LOGIN SHELL LOGIC] ---
      # 处理“Login Shell”（如 SSH 登录）的环境变量。
      # 确保路径传递与 .bashrc 的自动引入。
      profileExtra = ''
        # 加载 Nix 环境
        if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
          . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        fi

        # 确保登录时也能引入 .bashrc
        if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
          . "$HOME/.bashrc"
        fi
      '';

      # --- [INTERACTIVE SHELL EXTRA] ---
      initExtra = ''
        # --- 实用函数：快速创建并进入目录 ---
        mkcd() { mkdir -p "$1" && cd "$1"; }

        # --- Micromamba 懒加载函数包装器 ---
        # 原理：仅在调用时注入 Shell Hook，优化 Shell 启动速度。
        micromamba() {
          if [ -f "${pkgs.micromamba}/bin/micromamba" ]; then
             eval "$(${pkgs.micromamba}/bin/micromamba shell hook -s bash)"
             unset -f micromamba
             micromamba "$@"
          else
             echo "❌ Micromamba not found in Nix Store!"
          fi
        }
        alias mamba='micromamba'
        alias conda='micromamba'

        # --- Home-Manager 维护函数：集成格式化、构建与自动提交 ---
        hm-save() {
          local msg="Update: $(date '+%Y-%m-%d %H:%M:%S')"
          if [ -n "$1" ]; then msg="Update: $1"; fi
          (
            cd ~/.config/home-manager || return
            echo "🧹 Running nix fmt..."
            nix fmt . &>/dev/null
            git add .
            echo "⚙️  Switching configuration..."
            if home-manager switch --flake ".#${hostName}" -b backup; then
              if [[ -n $(git diff --cached) ]]; then
                git commit -m "$msg"
                echo "🎉 Successful! Committed: $msg"
              else
                echo "ℹ️ No changes detected in config."
              fi
            else
              echo "❌ Build failed. Check errors above."
              return 1
            fi
          )
        }

        # --- 系统一键更新与垃圾清理 ---
        hm-fix() {
          (
            cd ~/.config/home-manager || return
            echo "🔄 Updating Flake..."
            nix flake update
            echo "🗑️  Garbage collecting..."
            nix-collect-garbage --delete-older-than 10d
          )
        }

        # --- 多终端历史实时同步 (非破坏性追加) ---
        _sync_history() {
          history -a
          history -n
        }
        # 将历史同步加入 PROMPT_COMMAND，同时保护 Starship 等工具的钩子
        if [[ ";$PROMPT_COMMAND;" != *";_sync_history;"* ]]; then
          PROMPT_COMMAND="_sync_history''${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
        fi

        # --- 自动注入网络代理 (若 myOptions.proxy.enable 为 true) ---
        ${lib.optionalString proxy.enable ''
          export http_proxy="http://${proxy.address}"
          export https_proxy="http://${proxy.address}"
          export all_proxy="http://${proxy.address}"
          echo "🌐 System proxy enabled: ${proxy.address}"
        ''}
      '';
    };
  };
}
