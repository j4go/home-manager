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

  ######################## FZF Config Begin ########################
  # FZF 基础 UI 配置 (严格去除了预览逻辑，防止全局污染和报错)
  fzfConfig = [
    "--height 40%"
    "--layout=reverse"
    "--border"
    "--inline-info"
    "--color='header:italic'"
    "--bind 'ctrl-/:toggle-preview'"
  ];
  fzfConfigStr = builtins.concatStringsSep " " fzfConfig;
  # 搜索后端
  fzfCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
  # 智能预览逻辑 (彻底去除了内部所有单引号，确保 Bash export 绝对安全)
  # 逻辑：如果是目录则 eza，如果是文件则 bat，否则显示提示
  smartPreview = "[[ -d {} ]] && eza --tree --color=always --icons=auto --level=2 {} || [[ -f {} ]] && bat --style=numbers --color=always --line-range=:500 {} || echo No-preview-available";
  ######################## FZF Config End ########################
in {
  config = {
    programs = {
      zoxide = {
        enable = true;
        enableBashIntegration = true;
        options = ["--cmd cd"];
      };
      eza = {
        enable = true;
        enableBashIntegration = true;
        git = true;
        extraOptions = ["--group-directories-first" "--header"];
      };
      fzf = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        defaultOptions = fzfConfig; # 注入基础 UI
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
      historyControl = ["ignoreboth" "erasedups"];
      shellOptions = ["histappend" "checkwinsize" "globstar" "cdspell" "dirspell"];

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
        cat = "bat";
        man = "batman";
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
        dig = "doggo";
        nslookup = "doggo";
        ping = "gping";
        lg = "lazygit";
        su = "su -";
        m = "tldr";
      };

      initExtra = ''

        # --- FZF 环境变量强制注入 ---
        export FZF_DEFAULT_OPTS="${fzfConfigStr}"
        export FZF_DEFAULT_COMMAND="${fzfCommand}"

        # 历史记录 (Ctrl-R): 彻底隐藏预览窗，极致清爽
        export FZF_CTRL_R_OPTS="--preview-window hidden"

        # 文件搜索 (Ctrl-T): 使用不含单引号的智能预览逻辑
        export FZF_CTRL_T_OPTS="--preview '${smartPreview}'"
        export FZF_CTRL_T_COMMAND="${fzfCommand}"

        # 目录搜索 (Alt-C): 树状结构预览
        export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons=auto --level=2 {}'"

        export PROMPT_COMMAND="history -a; history -n"

        ${
          if proxy.enable
          then ''
            export http_proxy="http://${proxy.address}"
            export https_proxy="http://${proxy.address}"
            export all_proxy="http://${proxy.address}"
          ''
          else ""
        }

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

              # 1. 🟢 关键：先 git add，让 Nix 能“看见”新文件
              # 这不会提交，只是把文件放进暂存区
              git add .

              # 2. 🟢 执行格式化，显式指定目录
              echo -e "🧹 Running nix fmt..."
              if ! nix fmt .; then
                  echo -e "❌ Format failed!"
                  return 1
              fi

              # 3. 🟢 再次 git add (重要)
              # 因为格式化会修改文件内容，我们需要把格式化后的改动再次放入暂存区
              git add .

              # 4. 构建与切换
              FLAKE_NAME="${hostName}"
              if home-manager switch --flake ".#$FLAKE_NAME" -b backup; then
                  echo -e "🎉 Switch Successful!"
                  [[ $(git diff --cached) ]] && git commit -m "Update: $(date '+%Y-%m-%d %H:%M:%S')" || echo "ℹ️ No changes."
              else
                  return 1
              fi
          )
        }

        hm-fix() {
            cd ~/.config/home-manager || return
            nix flake update && nix-collect-garbage --delete-older-than 10d
        }

      '';
    };
  };
}
