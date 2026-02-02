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

  # 提取常用命令路径，避免 PATH 依赖
  ezaExe = lib.getExe pkgs.eza;
  batExe = lib.getExe pkgs.bat;
  fdExe = lib.getExe pkgs.fd;

  noProxyList = ["localhost" "127.0.0.1" "::1" "192.168.0.0/16" "172.16.0.0/12" "10.0.0.0/8" "*.local" ".lan"];
  noProxyStr = builtins.concatStringsSep "," noProxyList;

  # 预览逻辑
  fzfPreviewDir = "${ezaExe} --tree --color=always --icons=auto --level=2 {}";
  fzfPreviewFile = "${batExe} --style=numbers --color=always --line-range=:500 {}";
  smartPreview = "[[ -d {} ]] && ${fzfPreviewDir} || [[ -f {} ]] && ${fzfPreviewFile} || echo 'No preview available'";
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
      fd
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
        defaultCommand = "${fdExe} --type f --strip-cwd-prefix --hidden --follow --exclude .git";
        defaultOptions = [
          "--height 40%"
          "--layout=reverse"
          "--border"
          "--inline-info"
          "--color='header:italic'"
          "--bind 'ctrl-/:toggle-preview'"
        ];
        fileWidgetCommand = "${fdExe} --type f --strip-cwd-prefix --hidden --follow --exclude .git";
        fileWidgetOptions = ["--preview '${smartPreview}'"];
        changeDirWidgetCommand = "${fdExe} --type d --strip-cwd-prefix --hidden --follow --exclude .git";
        changeDirWidgetOptions = ["--preview '${fzfPreviewDir}'"];
      };
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;
      historySize = 1000000;
      historyFileSize = 1000000;
      historyControl = ["ignoreboth" "erasedups"];

      shellOptions = [
        "histappend"
        "checkwinsize"
        "globstar"
        "cdspell"
        "dirspell"
        "checkjobs"
        "histverify"
      ];

      sessionVariables = {
        EDITOR = "nvim";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        PYTHONPYCACHEPREFIX = "/tmp/python-cache";
        MANPAGER =
          if hasBat
          then "sh -c 'col -bx | ${batExe} -l man -p'"
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
          hm = "cd ~/.config/home-manager/";
          setproxy = "export all_proxy=http://${proxy.address} http_proxy=http://${proxy.address} https_proxy=http://${proxy.address} no_proxy=${noProxyStr} NO_PROXY=${noProxyStr}";
          unproxy = "unset all_proxy http_proxy https_proxy no_proxy NO_PROXY";
          gitup = "git add . && git commit -m \"update: $(date +%Y-%m-%d)\" && git push";
        }
        (lib.mkIf hasEza {
          ls = "${ezaExe} --icons=auto --git";
          ll = "${ezaExe} -l -a --icons=auto --git --time-style=relative";
          la = "${ezaExe} -l -a --icons=auto --git --time-style=relative";
          lt = "${ezaExe} --tree --level=2 --icons=auto --git --ignore-glob='.git|node_modules'";
        })
        (lib.mkIf hasBat {
          man = "batman";
          bgrep = "batgrep";
          bdiff = "batdiff";
        })
      ];

      profileExtra = ''
        if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
          . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi
        if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        fi
      '';

      initExtra = ''
        # 这里的逻辑只在交互式终端运行
        [[ $- == *i* ]] || return

        # 2. 实用函数
        mkcd() { mkdir -p "$1" && cd "$1"; }

        # 3. Micromamba 懒加载 (使用绝对路径避免 Hash 失效)
        micromamba() {
          local bin="${lib.getExe pkgs.micromamba}"
          if [ -f "$bin" ]; then
             eval "$($bin shell hook -s bash)"
             unset -f micromamba
             micromamba "$@"
          else
             echo "❌ Micromamba not found!"
          fi
        }
        alias mamba='micromamba'
        alias conda='micromamba'

        # 4. HM 维护函数
        hm-save() {
          local msg="Update: $(date '+%Y-%m-%d %H:%M:%S')"
          if [ -n "$1" ]; then msg="Update: $1"; fi
          (
            cd ~/.config/home-manager || return
            # 它会自动调用你 flake.nix 里定义的 alejandra
            if command -v nix >/dev/null; then
              nix fmt . &>/dev/null
            fi
            git add .
            if home-manager switch --flake ".#${hostName}" -b backup; then
              [[ -n $(git diff --cached) ]] && git commit -m "$msg" && echo "🎉 Successful!" || echo "ℹ️ No changes."
            else
              return 1
            fi
          )
        }

        # 5. 历史同步优化
        _sync_history() { history -a; history -n; }
        if [[ ";$PROMPT_COMMAND;" != *";_sync_history;"* ]]; then
          PROMPT_COMMAND="_sync_history''${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
        fi

        # 6. 自动代理注入 (交互式提示)
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
