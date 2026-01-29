{ config, lib, ... }:
let
  # 修正后的 inherit 列表，去掉了不存在的 displayTab，增加了 text
  inherit (config.lib.htop) leftMeters rightMeters bar text graph led;
in
{
  programs.htop = {
    enable = true;
    settings = {
      tree_view = 1;
      show_program_path = 0;
      highlight_base_name = 1;
      highlight_megabytes = 1;
      shadow_other_users = 1;
      show_thread_names = 1;
    } // (with config.lib.htop; leftMeters [
      (bar "AllCPUs")
      (bar "Memory")
      (bar "Swap")
    ]) // (with config.lib.htop; rightMeters [
      (text "Tasks")          # 替代 displayTab
      (text "LoadAverage")    # 替代 displayTab
      (text "Uptime")         # 替代 displayTab
      (text "Battery")        # 替代 displayTab
    ]);
  };
}
