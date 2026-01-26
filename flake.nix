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
      # Rocky Linux 9.7
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
      # Rocky Linux 10.1
      # 对应命令: nix run ... -- switch --flake .#rocky
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
      # Linux Mint
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
      # Fedora
      # 对应命令: nix run ... -- switch --flake .#fedora
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
