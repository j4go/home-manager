{...}: {
  imports = [
    ./tools.nix
    ./dev # 自动寻找 modules/dev/default.nix
    ./shell # 自动寻找 modules/shell/default.nix
  ];
}
