{
  description = "My Multi-Host Home Manager Configuration";

  inputs = {
    # 指定 Nixpkgs 源 (建议使用 unstable 以获取最新软件，或 release-24.11 求稳)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    homeConfigurations = {
      # 🖥️ 配置一：Rocky Linux 
      # 对应命令: nix run ... -- switch --flake .#rocky
      "rocky" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home.nix
          {
            home.username = "w";
            home.homeDirectory = "/home/w";
          }
        ];
      };
      # 💻 配置二：Linux Mint
      # 对应命令: nix run ... -- switch --flake .#mint
      "mint" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home.nix
          {
            home.username = "w";
            home.homeDirectory = "/home/w";
            # 你甚至可以在这里添加 Mint 特有的配置
            # home.packages = [ pkgs.hello ];
          }
        ];
      };
    };
  };
}
