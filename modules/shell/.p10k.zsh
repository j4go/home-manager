# =============================================================================
# 🏆 Industry Standard: Lean Style (Minimalist & Pragmatic)
# =============================================================================
() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # 1. 核心显示元素 (左侧)
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context                   # 仅在 SSH/Root 时显示
    dir                       # 路径 (智能缩写)
    vcs                       # Git 状态 (异步加载)
    command_execution_time    # 命令耗时
    nix_shell                 # Nix 状态
    prompt_char               # 提示符
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=() # 大佬通常保持右侧清空以减少视觉干扰

  # 2. 视觉风格：扁平化 (Lean)
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_BACKGROUND=                # 无背景色
  typeset -g POWERLEVEL9K_ICON_PADDING=none          # 紧凑图标
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true    # 命令间留白，增加可读性

  # 3. 路径逻辑 (业界最佳实践：保留 3 级目录)
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=31          # 经典的青蓝色
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_DIR_SHORTEN_DIR_LENGTH=3
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true       # 关键目录加粗

  # 4. Git 状态 (使用 p10k 极致优化的 gitstatusd)
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76    # 绿色
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178 # 橙色
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=39 # 蓝色

  # 5. 交互特性
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always    # 执行后收缩提示符，保持屏幕整洁
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose     # 开启即时提示，解决加载延迟
}
