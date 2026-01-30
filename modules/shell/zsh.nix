{
  config,
  lib,
  pkgs,
  inputs,
  system,
  hostName,
  ...
}: let
  cfg = config.myOptions.shell.zsh;
  proxy = config.myOptions.proxy;
in {
  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      ];
    };

    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;

      history = {
        size = 1000000;
        save = 1000000;
        path = "$HOME/.zsh_history";
        ignoreAllDups = true;
        share = true;
      };

      sessionVariables = {
        EDITOR = "nvim";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        PYTHONPYCACHEPREFIX = "/tmp/python-cache";

        # 让 Zsh 下的 man 手册也支持 bat 高亮
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
      };

      shellAliases = {
        # Bat 现代化替代方案
        cat = "bat";
        man = "batman";
        bgrep = "batgrep";
        bdiff = "batdiff";

        "7z" = "7zz";
        grep = "grep --color=auto";
        l = "eza -lh --icons=auto";
        ll = "eza -lha --icons=auto --sort=name --group-directories-first";
        la = "eza -a --icons=auto";
        lt = "eza --tree --level=2 --icons=auto";
        h = "history";
        so = "source ~/.zshrc";
        gitup = "git add . && git commit -m \"update: $(date +%Y-%m-%d)\" && git push";
        rm = "trash-put";
        f = "pay-respects";
        setproxy = "export all_proxy=http://${proxy.address} http_proxy=http://${proxy.address} https_proxy=http://${proxy.address}";
        unproxy = "unset all_proxy http_proxy https_proxy";
      };

      initContent = lib.mkMerge [
        ''
          # Zsh 补全样式优化
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
          zstyle ':completion:*' menu select

          ${
            if proxy.enable
            then ''
              export http_proxy="http://${proxy.address}"
              export https_proxy="http://${proxy.address}"
              export all_proxy="http://${proxy.address}"
              export no_proxy="localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,*.local,*.internal"
            ''
            else "# Proxy disabled"
          }

          # Mamba 延迟加载
          mamba_setup() {
              local mamba_path="''${HOME}/.nix-profile/etc/profile.d"
              if [[ -f "$mamba_path/conda.sh" ]]; then
                  source "$mamba_path/conda.sh"
                  source "$mamba_path/mamba.sh"
              fi
              unalias mamba conda 2>/dev/null
              unfunction mamba_setup
          }
          alias mamba='mamba_setup; mamba'
          alias conda='mamba_setup; conda'

          # 快速编辑/创建文件
          edit() {
              for file in "$@"; do [[ ! -e "$file" ]] && touch "$file" && echo "📄 Created: $file"; done
              $EDITOR "$@"
          }

          # Home Manager 运维函数
          hm-save() {
            cd ~/.config/home-manager || return
            git add .
            FLAKE_NAME="${hostName}"
            if home-manager switch --flake ".#$FLAKE_NAME" -b backup; then
                echo "🎉 Switch Successful!"
                [[ $(git diff --cached) ]] && git commit -m "Update from $FLAKE_NAME: $(date '+%Y-%m-%d %H:%M:%S')" || echo "ℹ️ No changes."
            else
                return 1
            fi
          }

          hm-fix() {
            cd ~/.config/home-manager || return
            nix flake update && nix-collect-garbage --delete-older-than 10d
          }
        ''
      ];
    };
  };
}
