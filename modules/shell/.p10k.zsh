# =============================================================================
# Starship-Clone Style Powerlevel10k Config (Tomorrow Night Optimized)
# =============================================================================

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # -------------------------------------------------------------------------
  # 1. 核心布局 (完全模拟您的 Starship 顺序)
  # -------------------------------------------------------------------------
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context                 # 用户名 @ 主机名
    dir                     # 目录 (无图标)
    vcs                     # Git
    nix_shell               # Nix Shell
    command_execution_time  # 耗时
    prompt_char             # ➜ 提示符
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # -------------------------------------------------------------------------
  # 2. 全局样式 (彻底扁平化)
  # -------------------------------------------------------------------------
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_BACKGROUND=               # 无背景
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='' # 禁用色块连接符
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''

  # 紧凑型间距
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_LEFT_LEFT_WHITESPACE=''
  typeset -g POWERLEVEL9K_LEFT_RIGHT_WHITESPACE=' '

  # -------------------------------------------------------------------------
  # 3. 模块级精修 (核心修正点)
  # -------------------------------------------------------------------------

  # [Context] - 用户名 @ 主机名 (模拟 w @ fedora)
  # 颜色对应 Starship: bold #ffaf00 (ANSI yellow)
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND='yellow'
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND='yellow'
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND='yellow'
  # 移除默认的 icon 和显示逻辑限制，使其始终显示
  typeset -g POWERLEVEL9K_CONTEXT_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_CONTEXT_PREFIX=''
  # 模板修改为 %n @ %m (n=user, m=host)
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n @ %m'
  # 确保在本地也显示 (模拟您的截图)
  unset POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION

  # [Directory] - 目录 (修正 .../ 和图标问题)
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='cyan'
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='cyan'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='cyan'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  # 关键：彻底移除文件夹图标
  typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION=''
  # 关键：实现 Starship 的 truncation_length = 2 (不显示 .../)
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=0
  typeset -g POWERLEVEL9K_DIR_SHORTEN_STRATEGY=truncate_to_last
  typeset -g POWERLEVEL9K_DIR_SHORTEN_DIR_LENGTH=2
  typeset -g POWERLEVEL9K_DIR_SHORTEN_DELIMITER='' # 移除省略号前缀
  # 移除锁图标 (针对只读目录)
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=false

  # [VCS] - Git 分支 (Purple)
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='magenta'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='magenta'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='magenta'
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION='' # 移除额外的 Git 图标，仅保留 branch_icon
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=false
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='(${P9K_CONTENT})'

  # [Character] - ➜ (强制绿色)
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND='green'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND='red'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='➜'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='✖'
  # 移除可能存在的缩进
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_LEFT_WHITESPACE=''

  # [Nix Shell] - (❄️ nix-shell)
  typeset -g POWERLEVEL9K_NIX_SHELL_FOREGROUND='blue'
  typeset -g POWERLEVEL9K_NIX_SHELL_VISUAL_IDENTIFIER_EXPANSION='❄️ '
  typeset -g POWERLEVEL9K_NIX_SHELL_CONTENT_EXPANSION='(nix-shell)'

  # [Command Duration] - took 10s
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=248
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX='took '

  # -------------------------------------------------------------------------
  # 4. 环境控制
  # -------------------------------------------------------------------------
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false # 强制单行显示，不换行
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
}
