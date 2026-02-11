{pkgs, ...}: {
  programs.nixvim.enable = false;
  home.packages = with pkgs; [
    neovim
    tree-sitter
    nodejs
  ];
}
