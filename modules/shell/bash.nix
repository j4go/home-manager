{
  config,
  lib,
  pkgs,
  hostName,
  ...
}: let
  # --- 变量提取 ---
  proxy = config.myOptions.proxy;
  hasBat = config.programs.bat.enable;
  hasEza = config.programs.eza.enable;

  noProxyList = ["localhost" "127.0.0.1" "::1" "192.168.0.0/16" "172.16.0.0/12" "10.0.0.0/8" "*.local" ".lan"];
  noProxyStr = builtins.concatStringsSep "," noProxyList;

  fzfPreviewDir = "eza --tree --color=always --icons=auto --level=2 {}";
  fzfPreviewFile = "bat --style=numbers --color=always --line-range=:500 {}";
  smartPreview = "[[ -d {} ]] && ${fzfPreviewDir} || [[ -f {} ]] && ${fzfPreviewFile} || echo No-preview-available";
in {
  config = {
    home.packages = with pkgs; [
      trash-cli
      fastfetch
      micromamba
      figlet
      toilet
      chafa
      lolcat
    ];

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
        defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
        defaultOptions = ["--height 40%" "--layout=reverse" "--border" "--inline-info" "--color='header:italic'" "--bind 'ctrl-/:toggle-preview'"];
        fileWidgetCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
        fileWidgetOptions = ["--preview '${smartPreview}'"];
        changeDirWidgetCommand = "fd --type d --strip-cwd-prefix --hidden --follow --exclude .git";
        changeDirWidgetOptions = ["--preview '${fzfPreviewDir}'"];
      };
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;
      historySize = 1000000;
      historyFileSize = 1000000;
      historyControl = ["ignoreboth" "erasedups"];

      shellOptions = ["histappend" "checkwinsize" "globstar" "cdspell" "dirspell" "checkjobs" "histverify"];

      sessionVariables = {
        EDITOR = "nvim";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        PYTHONPYCACHEPREFIX = "/tmp/python-cache";
        MANPAGER =
          if hasBat
          then "sh -c 'col -bx | bat -l man -p'"
          else "less";
        MANROFFOPT = "-c";
        NO_PROXY = noProxyStr;
        no_proxy = noProxyStr;
      };

      shellAliases = lib.mkMerge [
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
          ze = "zellij";
          zew = "zellij attach w -c";
          zels = "zellij list-sessions";
          setproxy = "export all_proxy=http://${proxy.address} http_proxy=http://${proxy.address} https_proxy=http://${proxy.address} no_proxy=${noProxyStr} NO_PROXY=${noProxyStr}";
          unproxy = "unset all_proxy http_proxy https_proxy no_proxy NO_PROXY";
          hm = "cd ~/.config/home-manager/";
          gitup = "git add . && git commit -m \"update: $(date +%Y-%m-%d)\" && git push";
        }
        (lib.mkIf hasEza {
          ls = "eza --icons=auto --git";
          ll = "eza -l -a --icons=auto --git --time-style=relative";
          la = "eza -l -a --icons=auto --git --time-style=relative";
          lt = "eza --tree --level=2 --icons=auto --git --ignore-glob='.git|node_modules'";
        })
        (lib.mkIf hasBat {
          man = "batman";
          bgrep = "batgrep";
          bdiff = "batdiff";
        })
      ];

      # --- [NIX BOOTSTRAP] ---
      # 这里的逻辑非常纯粹：只负责把 Nix 塞进 PATH。
      bashrcExtra = ''
        if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
          . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        fi

        # 双重保险：确保用户 profile 也在 PATH 中
        if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi
      '';

      # --- [LOGIN SHELL LOGIC] ---
      # 确保 SSH 登录时也能拿到正确环境
      profileExtra = ''
        if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
          . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        fi
        if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
          . "$HOME/.bashrc"
        fi
      '';

      # --- [INTERACTIVE SHELL EXTRA] ---
      initExtra = ''
        # 实用函数
        mkcd() { mkdir -p "$1" && cd "$1"; }

        # Micromamba 懒加载
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

        # HM 维护函数
        hm-save() {
          local msg="Update: $(date '+%Y-%m-%d %H:%M:%S')"
          if [ -n "$1" ]; then msg="Update: $1"; fi
          (
            cd ~/.config/home-manager || return
            nix fmt . &>/dev/null
            git add .
            if home-manager switch --flake ".#${hostName}" -b backup; then
              [[ -n $(git diff --cached) ]] && git commit -m "$msg" && echo "🎉 Successful!" || echo "ℹ️ No changes."
            else
              return 1
            fi
          )
        }

        # 系统修复函数
        hm-fix() {
          ( cd ~/.config/home-manager && nix flake update && nix-collect-garbage --delete-older-than 10d )
        }

        # 历史同步
        _sync_history() { history -a; history -n; }
        if [[ ";$PROMPT_COMMAND;" != *";_sync_history;"* ]]; then
          PROMPT_COMMAND="_sync_history''${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
        fi

        # 代理注入
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
