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
  fzfCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
  smartPreview = "[[ -d {} ]] && eza --tree --color=always --icons=auto --level=2 {} || [[ -f {} ]] && bat --style=numbers --color=always --line-range=:500 {} || echo No-preview-available";
in {
  config = {
    programs = {
      # 智能目录跳转
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
        defaultCommand = fzfCommand;
        defaultOptions = [
          "--height 40%"
          "--layout=reverse"
          "--border"
          "--inline-info"
          "--color='header:italic'"
          "--bind 'ctrl-/:toggle-preview'"
        ];
        fileWidgetCommand = fzfCommand;
        fileWidgetOptions = ["--preview '${smartPreview}'"];
        changeDirWidgetCommand = "fd --type d --strip-cwd-prefix --hidden --follow --exclude .git";
        changeDirWidgetOptions = ["--preview 'eza --tree --color=always --icons=auto --level=2 {}'"];
      };

      # 命令纠错工具
      pay-respects = {
        enable = true;
        enableBashIntegration = true;
      };
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;

      # 历史记录持久化与去重
      historySize = 1000000;
      historyFileSize = 1000000;
      historyControl = ["ignoreboth" "erasedups"];

      # Shell 行为微调：自动更正路径拼写、检查窗口大小、并发作业检查
      shellOptions = [
        "histappend"
        "checkwinsize"
        "globstar"
        "cdspell"
        "dirspell"
        "checkjobs"
      ];

      # 全局环境变量
      sessionVariables = {
        EDITOR = "nvim";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        PYTHONPYCACHEPREFIX = "/tmp/python-cache";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
        NO_PROXY = noProxyStr;
        no_proxy = noProxyStr;
        # 禁用dnf插件
        DNF5_COMMAND_NOT_FOUND_DISABLE = "1";
        DNF5_CNF_DISABLED = "1";
        COMMAND_NOT_FOUND_AUTO_INSTALL = "never";
        CONF_SW_NO_PROMPT = "1";
      };

      # 别名系统：分类管理
      shellAliases = {
        os = "fastfetch";
        neo = "fastfetch";
        fetch = "fastfetch";
        su = "su -";
        "7z" = "7zz";
        so = "source ~/.bashrc";
        ls = "eza --icons=auto --git";
        ll = "eza -l -a --icons=auto --git --time-style=relative";
        la = "ll";
        lt = "eza --tree --level=2 --icons=auto --git --ignore-glob='.git|node_modules'";
        m = "tldr";
        man = "batman";
        bgrep = "batgrep";
        bdiff = "batdiff";
        grep = "grep --color=auto";
        rm = "trash-put";
        h = "history";
        lg = "lazygit";
        f = "pay-respects";
        ping = "gping";
        dig = "doggo";
        print = "figlet";

        # zellij 常用
        ze = "zellij";
        zels = "zellij list-sessions";

        # 代理手动控制
        setproxy = "export all_proxy=http://${proxy.address} http_proxy=http://${proxy.address} https_proxy=http://${proxy.address} no_proxy=${noProxyStr} NO_PROXY=${noProxyStr}";
        unproxy = "unset all_proxy http_proxy https_proxy no_proxy NO_PROXY";

        # Nix/Home-Manager 工作流
        hm = "cd ~/.config/home-manager/";
        gitup = "git add . && git commit -m \"update: $(date +%Y-%m-%d)\" && git push";
      };

      initExtra = lib.mkAfter ''
        # --- Zellij 自动启动与会话锁定逻辑 ---
        # 逻辑：
        # 1. 检查当前是否已在 Zellij 会话中 ($ZELLIJ 变量为空)
        # 2. 检查当前是否为交互式 Shell ($- 包含 i)
        # 3. 排除 SSH 远程连接或特定的 IDE 终端 (可选)
        if [[ -z "$ZELLIJ" && $- == *i* ]]; then
          if command -v zellij &> /dev/null; then
            # attach: 尝试连接
            # -c w: 如果名为 "w" 的会话不存在，则以 "w" 为名创建它
            # zellij attach -c w
            # exec: 让 Zellij 替换当前的 bash 进程，退出时直接关闭终端窗口
            exec zellij attach -c w
          fi
        fi

        # 注入补全脚本 (即便不自动启动，补全也是必要的)
        if command -v zellij &> /dev/null; then
          eval "$(zellij setup --generate-completion bash)"
        fi


        # --- 彻底粉碎 DNF 搜索建议 ---

        # 清理信号捕捉（切断二进制钩子）
        trap - ERR
        trap - DEBUG

        # 影子函数：劫持系统自愈逻辑，使其失效
        __dnf5_command_not_found_setup() { :; }
        __dnf5_command_not_found_handler() { :; }

        # 定义纯净报错函数，覆盖系统默认行为
        command_not_found_handle() {
          printf "bash: %s: command not found\n" "$1" >&2
          return 127
        }
        command_not_found_handler() {
          command_not_found_handle "$@"
        }

        # 同步终端历史
        export PROMPT_COMMAND="history -a; history -n"

        if command -v starship >/dev/null; then
          eval "$(starship init bash)"
        fi


        # 使用“历史扩展”符号（如 !!、!$、!n 等）时，系统不会立即执行该命令，而是先将扩展后的完整命令展示在你的输入行中;
        # 允许你预览、修改，再次按下回车后才会真正执行。它是防止误操作、提升终端操作确定性的关键配置。
        shopt -s histverify


        # 自动注入网络代理（若启用）
        ${lib.optionalString proxy.enable ''
          export http_proxy="http://${proxy.address}"
          export https_proxy="http://${proxy.address}"
          export all_proxy="http://${proxy.address}"
        ''}


        # Mamba/Conda 懒加载：仅在调用时加载环境，优化启动速度
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


        # 实用函数：快速创建并进入目录
        mkcd() { mkdir -p "$1" && cd "$1"; }


        # Home-Manager 维护函数：集成格式化、构建与自动提交
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


        # 系统清理与更新
        hm-fix() {
          cd ~/.config/home-manager || return
          nix flake update && nix-collect-garbage --delete-older-than 10d
        }

      '';
    };
  };
}
