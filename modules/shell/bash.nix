{ config, lib, pkgs, inputs, system, hostName, ... }:
let
  proxy = config.myOptions.proxy;
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
in {
  config = {
    programs = {
      eza = {
        enable = true;
        package = unstablePkgs.eza; 
        enableBashIntegration = true;
        icons = "auto";
        git = true;
      };
      zoxide = {
        enable = true;
        enableBashIntegration = true;
      };
      fzf = {
        enable = true;
        enableBashIntegration = true;
        defaultOptions = [
          "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
        ];
      };
      pay-respects = {
        enable = true;
        enableBashIntegration = false;
      };
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;

      historySize = 1000000;
      historyFileSize = 1000000;
      historyControl = [ "ignoreboth" "erasedups" ];

      shellOptions = [ 
        "histappend" "checkwinsize" "globstar" "cdspell" "dirspell" 
      ];

      sessionVariables = {
        EDITOR = "nvim";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        PYTHONPYCACHEPREFIX = "/tmp/python-cache";
        
        # 让系统默认的 man 手册使用 bat 进行渲染
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
      };

      shellAliases = {
        # Bat 现代化替代方案
        cat   = "bat";
        man   = "batman";      # 需要 bat-extras.batman
        bgrep = "batgrep";     # 需要 bat-extras.batgrep
        bdiff = "batdiff";     # 需要 bat-extras.batdiff

        "7z" = "7zz";
        l = "eza -lh --icons=auto"; 
        ll = "eza -lha --icons=auto --sort=name --group-directories-first";
        la = "eza -a --icons=auto";
        lt = "eza --tree --level=2 --icons=auto";
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
      };

      initExtra = ''
        # sync history
        export PROMPT_COMMAND="history -a; history -n"

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
          git add .
          FLAKE_NAME="${hostName}" 
          if home-manager switch --flake ".#$FLAKE_NAME" -b backup; then
              echo -e "🎉 Switch Successful!"
              [[ $(git diff --cached) ]] && git commit -m "Update from $FLAKE_NAME: $(date '+%Y-%m-%d %H:%M:%S')" || echo "ℹ️ No changes."
          else
              return 1
          fi
        )}

        hm-fix() {
          (
            cd ~/.config/home-manager || return
            nix flake update && nix-collect-garbage --delete-older-than 10d 
          )
        }
      '';
    };
  };
}
