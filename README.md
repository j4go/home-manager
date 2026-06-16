# Home Manager 多主机配置

基于 Nix Flake + Home Manager 的声明式用户环境管理，统一管理多台 Linux 主机的开发工具链、Shell 配置和点文件。

## 主机概览

| 主机 | 架构 | 代理状态 | 代理地址 |
|------|------|----------|----------|
| mint | x86_64-linux | 关闭 | 192.168.11.253:10808 |
| alma | x86_64-linux | 关闭 | 192.168.11.253:10808 |
| fedora | aarch64-linux | 开启 | 192.168.3.248:10808 |
| rocky10 | aarch64-linux | 开启 | 192.168.3.248:10808 |

所有主机共享用户名 `w`，主目录 `/home/w`。

## 目录结构

```
.
├── flake.nix            # Flake 入口，定义依赖和 mkHome 编排函数
├── flake.lock           # 依赖锁文件
├── home.nix             # 核心枢纽：自定义选项、环境变量、别名，导入子模块
├── basic_tools.nix      # 无需额外配置的独立 CLI 工具集合
├── nh.nix               # Nix Helper (nh) 配置与自动清理策略
├── .editorconfig        # 编辑器缩进规范
│
├── env/                 # 开发环境
│   ├── default.nix
│   ├── direnv.nix       # direnv + nix-direnv 缓存，含 layout_python_flex 自定义函数
│   └── python.nix       # micromamba + uv，Python 环境管理
│
├── shell/               # Shell 配置
│   ├── default.nix
│   ├── bash.nix         # Bash 配置：懒加载、yazi wrapper、hm-save、代理注入
│   └── starship.nix     # Starship 提示符
│
├── tools/               # 需要深度配置的工具
│   ├── default.nix
│   ├── neovim.nix       # Neovim (nixvim)：catppuccin、telescope、lsp、cmp、treesitter
│   ├── git.nix          # Git + Lazygit + Delta
│   ├── ssh.nix          # SSH 连接复用与代理
│   ├── yazi.nix         # Yazi 文件管理器 + 插件
│   ├── zellij.nix       # Zellij 终端复用器
│   ├── bat.nix          # bat 语法高亮 + bat-extras
│   ├── btop.nix         # btop 系统监控
│   └── htop.nix         # htop 进程管理
│
├── hosts/               # 主机特定配置（仅定义代理开关、用户名、主目录）
│   ├── mint/default.nix
│   ├── alma/default.nix
│   ├── fedora/default.nix
│   └── rocky10/default.nix
│
└── standby/             # 暂未启用的实验性配置
    ├── broot.nix
    └── snitch.nix
```

## 模块加载流程

```
flake.nix (mkHome)
  ├── home.nix (通用基础)
  │     ├── nh.nix
  │     ├── basic_tools.nix
  │     ├── env/  (direnv + python)
  │     ├── shell/ (bash + starship)
  │     └── tools/ (neovim, git, ssh, yazi, zellij, bat, btop, htop)
  ├── hosts/<hostname>/ (主机特定覆盖)
  └── nixvim (外部插件模块)
```

## 代理配置

通过 `myOptions.proxy` 实现按主机控制代理，**只需在 `hosts/<hostname>/default.nix` 中修改一次地址**，所有消费方自动同步：

- `myOptions.proxy.enable` — 是否在当前主机自动注入代理环境变量
- `myOptions.proxy.address` — 代理地址，默认 `192.168.11.253:10808`

传播链路：

```
hosts/<hostname>/default.nix  (唯一修改点)
    │  myOptions.proxy = { enable; address; }
    │
    ├── shell/bash.nix   → 登录时自动注入 http_proxy / https_proxy / all_proxy
    ├── home.nix         → setproxy / unproxy 别名
    ├── tools/git.nix    → http.proxy / https.proxy
    └── tools/ssh.nix    → GitHub SSH proxyCommand
```

## 常用别名速查

| 别名 | 命令 | 说明 |
|------|------|------|
| `v` | `vim` | 编辑器 |
| `lg` | `lazygit` | Git TUI |
| `m` | `tldr` | 命令速查 |
| `ya` / `y` | `yazi` | 文件管理器（y 带目录跳转） |
| `ze` | `zellij` | 终端复用器 |
| `zew` | `zellij attach w -c` | 连接/创建 w 会话 |
| `os` | `fastfetch` | 系统信息 |
| `setproxy` / `unproxy` | — | 手动开关代理 |
| `hm` | `cd ~/.config/home-manager/` | 进入配置目录 |
| `hm-save` | — | 格式化 + 构建 + 提交一键保存 |
| `ls` / `ll` / `lt` | `eza` | 增强 ls（需 eza 启用） |
| `man` | `batman` | 高亮 man（需 bat 启用） |

## 快速使用

```bash
# 部署到当前主机
nh home switch ~/.config/home-manager

# 一键保存（格式化 + 构建 + git commit）
hm-save "描述信息"

# 清理旧 generation
nh clean all

# 查看 generation 差异
nvd diff /nix/store/... /nix/store/...
```

## 依赖与版本

- **nixpkgs**: nixos-25.11（稳定）
- **nixpkgs-unstable**: nixos-unstable（通过 overlay 引入，用于 hyperfine、bottom 等包）
- **home-manager**: release-25.11
- **nixvim**: 跟随 nixpkgs
- **home.stateVersion**: 25.11

## Nix 资源

- [nh — Nix Helper](https://github.com/nix-community/nh)
- [CLI Tools](https://terminaltrove.com/new/)
- [awesome-nix](https://github.com/nix-community/awesome-nix)
- [NixOS Package Search](https://search.nixos.org/packages)
