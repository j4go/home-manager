{pkgs, ...}: {
  home.packages = with pkgs; [
    micromamba
    uv
  ];

  home.sessionVariables = {
    MAMBA_ROOT_PREFIX = "$HOME/.micromamba";
  };

  home.activation.createMambaRoot = ''
    mkdir -p $HOME/.micromamba
  '';
}
