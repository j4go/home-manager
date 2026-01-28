{ ... }: {
  imports = [
    ./packages.nix
    ./dev   # 自动寻找 modules/dev/default.nix
    ./shell
  ];
}
