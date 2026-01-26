{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    
    shellAliases = {
      ll = "ls -l";
      hm-update = "home-manager switch --flake ~/.config/home-manager -b backup";
    };
  };
}
