{ config, lib, pkgs, inputs, system, hostName, ... }:
let
  cfg = config.myOptions.shell.zsh;
  proxy = config.myOptions.proxy;
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
in {
  config = lib.mkIf cfg.enable {
    
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
      };

      shellAliases = {
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
        f = "fuck";
        setproxy = "export all_proxy=http://${proxy.address} http_proxy=http://${proxy.address} https_proxy=http://${proxy.address}";
        unproxy = "unset all_proxy http_proxy https_proxy";
      };

      initContent = lib.mkMerge [
        ''
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 
          zstyle ':completion:*' menu select

          # 代理配置
          ${if proxy.enable then ''
            export http_proxy="http://${proxy.address}"
            export https_proxy="http://${proxy.address}"
            export all_proxy="http://${proxy.address}"
            export no_proxy="localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,*.local,*.internal"
          '' else "# Proxy disabled"}

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

          edit() {
              for file in "$@"; do [[ ! -e "$file" ]] && touch "$file" && echo "📄 Created: $file"; done
              $EDITOR "$@"
          }

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
