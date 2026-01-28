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
      };

      pay-respects = {
        enable = true;
        enableBashIntegration = true;
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
      };

      shellAliases = {
        "7z" = "7zz";
        l = "eza -lh --icons=auto"; 
        ll = "eza -lha --icons=auto --sort=name --group-directories-first";
        la = "eza -a --icons=auto";
        lt = "eza --tree --level=2 --icons=auto";
        grep = "grep --color=auto";
        gitup = "git add . && git commit -m 'update: $(date +%Y-%m-%d)' && git push";
        rm = "trash-put";
        # ✅ 补全别名
        h = "history";
        so = "source ~/.bashrc";
        f = "fuck";
        setproxy = "export all_proxy=http://${proxy.address} http_proxy=http://${proxy.address} https_proxy=http://${proxy.address}";
        unproxy = "unset all_proxy http_proxy https_proxy";
      };

      initExtra = ''
        # 🤫 静态标题锁定 + 历史同步
        # 在 Bash 中，我们通过 printf 确保标题在每次提示符刷新时锁定
        export PROMPT_COMMAND="history -a; history -n"

        # 🌐 自动代理注入
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

        # 🚀 实用函数 
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
