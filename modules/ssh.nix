{ pkgs, vars, ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = { addKeysToAgent = "yes"; };

      "github.com" = {
        hostname = "github.com";
        user = "git";
        # 🚀 动态注入代理 IP
        proxyCommand = if vars.proxyHost != "" 
          then "${pkgs.netcat-openbsd}/bin/nc -X 5 -x ${vars.proxyHost} %h %p"
          else null;
      };
    };
  };
}
