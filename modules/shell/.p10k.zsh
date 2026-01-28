# =============================================================================
# 🚀 Powerlevel10k - Starship "Pixel-Perfect" Clone
# =============================================================================

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # 1. 布局顺序
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context                 # 仅 SSH 时显示
    dir                     # 路径
    vcs                     # Git
    nix_shell               # Nix
    command_execution_time  # 耗时
    prompt_char             # ➜
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # 2. 全局扁平化
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_LEFT_LEFT_WHITESPACE=''
  typeset -g POWERLEVEL9K_LEFT_RIGHT_WHITESPACE=' '

  # 3. 模块精修

  # [Context] - SSH 逻辑
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION='' 
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND='214'
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n @ %m'
  typeset -g POWERLEVEL9K_CONTEXT_VISUAL_IDENTIFIER_EXPANSION=''

  # [Directory] - 路径修复 (解决 ~/.co* 问题)
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='14' # Cyan
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='14'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION=''
  
  # ✅ 关键修正：禁用所有自动缩写，仅保留“项目根目录切断”逻辑
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=0             # 禁用长度限制，防止出现 *
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=''         # 禁用任何缩写策略
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=true # 开启切断功能
  # 只要看到这些文件，就认为这是项目起点，并删掉之前的所有路径
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER='(.git|flake.nix|default.nix)'

  # [VCS] - Git (Starship: 纯紫色，无对勾)
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
  typeset -g POWERLEVEL9K_VCS_FOREGROUND='13'         # Purple
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='13'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='13'
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=''
  # ✅ 关键修正：移除 ✓ 符号，仅显示分支名
  typeset -g POWERLEVEL9K_VCS_CLEAN_CONTENT_EXPANSION='${P9K_CONTENT}'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_CONTENT_EXPANSION='${P9K_CONTENT}'

  # [Character] - ➜
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND='green'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND='red'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='➜'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='✖'

  # [Command Duration] - took 25s (Starship: 亮黄色)
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
  # ✅ 关键修正：颜色改为 226 (亮黄)，对标 Starship 截图
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='226' 
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX='took '

  # [Nix Shell]
  typeset -g POWERLEVEL9K_NIX_SHELL_FOREGROUND='12'
  typeset -g POWERLEVEL9K_NIX_SHELL_VISUAL_IDENTIFIER_EXPANSION='❄️ '
  typeset -g POWERLEVEL9K_NIX_SHELL_CONTENT_EXPANSION='(nix-shell)'

  # 4. 性能与环境
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
}
