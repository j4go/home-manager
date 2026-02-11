{pkgs, ...}: {
  programs.nixvim.enable = false;
  home.packages = with pkgs; [
    neovim
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
