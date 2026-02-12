{
  config,
  lib,
  pkgs,
  ...
}: let
  proxy = config.myOptions.proxy;
in {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = ["ignoreboth" "erasedups"];

    # 仅保留 Bash 特有的调试别名
    shellAliases = {
      so = "source ~/.bashrc";
      bash-debug = "bash --login -x";
    };

    initExtra = ''
      [[ $- == *i* ]] || return

      mkcd() { mkdir -p "$1" && cd "$1"; }

      # Micromamba Lazy Load
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

      # HM Save
      hm-save() {
        local flake_path="$FLAKE"
        local msg="Update: $(date '+%Y-%m-%d %H:%M:%S')"
        if [ -n "$1" ]; then msg="Update: $1"; fi

        echo "🚀 Formatting..."
        nix fmt "$flake_path" &>/dev/null
        git -C "$flake_path" add .

        echo "🔨 Rebuilding..."
        if nh home switch "$flake_path"; then
          if [[ -n $(git -C "$flake_path" diff --cached) ]]; then
            git -C "$flake_path" commit -m "$msg"
            echo "✅ Done."
          else
            echo "ℹ No changes."
          fi
        else
          echo "❌ Failed."
          return 1
        fi
      }

      # History Sync
      _sync_history() { history -a; }
      if [[ ";$PROMPT_COMMAND;" != *";_sync_history;"* ]]; then
        PROMPT_COMMAND="_sync_history''${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
      fi

      # Proxy Injection
      ${lib.optionalString proxy.enable ''
        export http_proxy="http://${proxy.address}"
        export https_proxy="http://${proxy.address}"
        export all_proxy="http://${proxy.address}"
      ''}

      # Yazi Wrapper
      function y() {
        local tmp="$(mktemp -t yazi-cwd.XXXXXX)"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
        tput cnorm
      }
    '';
  };
}
