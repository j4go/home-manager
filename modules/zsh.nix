{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    
    shellAliases = {
      ll = "ls -l";
    };
  };
}
