{...}: {
  imports = [
    ./nh.nix
    ./basic_tools.nix
    ./tools # 自动寻找 modules/tools/default.nix
    ./env # 自动寻找 modules/env/default.nix
    ./shell # 自动寻找 modules/shell/default.nix
  ];
}
