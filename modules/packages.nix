{ pkgs, ... }: {
  home.packages = with pkgs; [
    ripgrep
    fd
    htop
    bat
    fzf
    jq
    xclip
    wl-clipboard
    fastfetch
  ];
}
