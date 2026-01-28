# =============================================================================
# 🚀 Powerlevel10k - Starship "Project-Aware" Edition
# -----------------------------------------------------------------------------
# 核心特性：项目感知路径、SSH 智能显示、扁平化视觉、极速响应
# =============================================================================

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # -------------------------------------------------------------------------
  # 1. 核心布局 (对标 Starship Format 顺序)
  # -------------------------------------------------------------------------
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context                 # 用户名 @ 主机名 (仅 SSH/Root)
    dir                     # 项目感知路径 (加粗锚点)
    vcs                     # Git 状态 (带 ✓ 符号)
    nix_shell               # Nix Shell 标识
    command_execution_time  # 执行耗时 (took 10s)
    prompt_char             # ➜ 提示符
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=() # 保持右侧清空

  # -------------------------------------------------------------------------
  # 2. 全局扁平化样式 (去色块、去分隔符)
  # -------------------------------------------------------------------------
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  
  # 紧凑间距设置
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_LEFT_LEFT_WHITESPACE=''
  typeset -g POWERLEVEL9K_LEFT_RIGHT_WHITESPACE=' '

  # -------------------------------------------------------------------------
  # 3. 模块级精修
  # -------------------------------------------------------------------------

  # [Context] - 仅在 SSH 或 Root 时显示 (Starship 逻辑)
  # 本地普通用户不显示内容
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION='' 
  # SSH/Root 样式 (亮橙色 214)
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND='214'
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND='214'
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n @ %m'
  typeset -g POWERLEVEL9K_CONTEXT_VISUAL_IDENTIFIER_EXPANSION=''

  # [Directory] - 项目感知路径 (核心优化点)
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='14' # Cyan
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='14'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='14'
  # ✅ 专家建议：加粗显示路径中的关键锚点
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  # 禁用文件夹图标
  typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION=''
  
  # ✅ 路径缩短策略：项目感知 (Project-Relative)
  # 只要目录下有 .git, flake.nix 等，就将其作为路径起点
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=true
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER='(.git|flake.nix|default.nix|home.nix)'
  # 即使缩写，也至少保留最后 2 级目录
  typeset -g POWERLEVEL9K_DIR_SHORTEN_DIR_LENGTH=2

  # [VCS] - Git 分支 (紫色 13)
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='13'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='13'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='13'
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=''
  # Git 干净时显示绿色对勾 (✓)
  typeset -g POWERLEVEL9K_VCS_CLEAN_CONTENT_EXPANSION='${P9K_CONTENT} %F{green}✓%f'

  # [Character] - ➜ 提示符
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND='green'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND='red'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='➜'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='✖'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_LEFT_WHITESPACE=''

  # [Nix Shell] - ❄️ (nix-shell)
  typeset -g POWERLEVEL9K_NIX_SHELL_FOREGROUND='12' # Blue
  typeset -g POWERLEVEL9K_NIX_SHELL_VISUAL_IDENTIFIER_EXPANSION='❄️ '
  typeset -g POWERLEVEL9K_NIX_SHELL_CONTENT_EXPANSION='(nix-shell)'

  # [Command Duration] - took 10s
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='246' # Dim Grey
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX='took '

  # -------------------------------------------------------------------------
  # 4. 环境与性能控制
  # -------------------------------------------------------------------------
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  
  # 禁用全局默认图标，保持极简
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=''
}
