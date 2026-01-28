{ config, lib, pkgs, inputs, system, ... }:

let
  cfg = config.myOptions.shell.zsh;
  proxy = config.myOptions.proxy;
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
in {
  config = lib.mkIf cfg.enable {
    
    programs = {
      eza = {
        enable = true;
        package = unstablePkgs.eza;
        enableZshIntegration = true;
        icons = "auto";
        git = true;
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };

      fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      # ✅ 修正点：移除 thefuck，改用业界推荐的 pay-respects
      pay-respects = {
        enable = true;
        enableZshIntegration = true;
      };
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
        DISABLE_AUTO_TITLE = "true"; 
      };

      shellAliases = {
        l = "eza -lh --icons=auto";
        ll = "eza -lha --icons=auto --sort=name --group-directories-first";
        la = "eza -a --icons=auto";
        lt = "eza --tree --level=2 --icons=auto";
        h = "history";
        so = "source ~/.zshrc";
        gitup = "git add . && git commit -m \"update: $(date +%Y-%m-%d)\" && git push";
        rm = "trash-put";
        
        # 代理控制
        setproxy = "export all_proxy=http://${proxy.address} http_proxy=http://${proxy.address} https_proxy=http://${proxy.address}";
        unproxy = "unset all_proxy http_proxy https_proxy";

        # ✅ 修正点：将 f 别名指向 pay-respects
        # pay-respects 默认命令是 'fuck'，我们将其映射为 'f'
        f = "fuck";
      };

      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = lib.cleanSource ./.;
          file = ".p10k.zsh";
        }
      ];

      initExtraFirst = ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';

      initExtra = ''
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 
        zstyle ':completion:*' menu select

        # 🤫 静态标题锁定
        case $TERM in
          xterm*|rxvt*)
            print -Pn "\e]0;Terminal\a"
            ;;
        esac

        # 🐍 Mamba/Conda 延迟加载
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

        # 🚀 实用函数
        function edit() {
            for file in "$@"; do
                [[ ! -e "$file" ]] && touch "$file" && echo "📄 Created: $file"
            done
            $EDITOR "$@"
        }
      '';
    };
  };
}
