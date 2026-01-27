{
  description = "My Multi-Host Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, ... }: {
    homeConfigurations = {
      # windows vb Rocky Linux 9.7 对应命令: nix run ... -- switch --flake .#rocky
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
      # windows vb Linux Mint 对应命令: nix run ... -- switch --flake .#mint
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
      # mac Rocky Linux 10.1 对应命令: nix run ... -- switch --flake .#rocky10
      "rocky10" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        modules = [
          ./home.nix
          {
            home.username = "w";
            home.homeDirectory = "/home/w";
          }
        ];
      };
      # mac Fedora 对应命令: nix run ... -- switch --flake .#fedora
      "fedora" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        modules = [
          ./home.nix
          {
            home.username = "w";
            home.homeDirectory = "/home/w";
          }
        ];
      };
    };
  };
}
