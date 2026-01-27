{ hostName }:

let
  # 1. 定义代理地址映射表
  proxyMap = {
    "rocky"   = "10.255.126.1:10808";
    "mint"    = "10.255.126.1:10808";
    "fedora"  = "192.168.3.248:10808";
    "rocky10" = "192.168.3.248:10808";
  };

  # 2. 获取当前主机的代理 IP
  currentProxy = proxyMap.${hostName} or "";
in
{
  # 导出给其他模块使用的变量
  proxyUrl = if currentProxy != "" then "http://${currentProxy}" else "";
  proxyHost = currentProxy;
  noProxy = "localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,*.local,*.internal";
}
