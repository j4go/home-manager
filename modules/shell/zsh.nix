{ config, lib, ... }:
let cfg = config.myOptions.shell.zsh;
in {
  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      shellAliases = {
        ll = "ls -l";
      };
    };
  };
}
