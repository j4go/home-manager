{ config, lib, pkgs, ... }:
let
  cfg = config.myOptions.dev.ssh;
  proxy = config.myOptions.proxy;
in {
  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = { addKeysToAgent = "yes"; };
        "github.com" = {
          hostname = "github.com";
          user = "git";
          proxyCommand = lib.mkIf proxy.enable 
            "${pkgs.netcat-openbsd}/bin/nc -X 5 -x ${proxy.address} %h %p";
        };
      };
    };
  };
}
