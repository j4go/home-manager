{ ... }: {
  imports = [
    ./dev   # 自动寻找 modules/dev/default.nix
    ./core
    ./shell
    ./editors
  ];
}
