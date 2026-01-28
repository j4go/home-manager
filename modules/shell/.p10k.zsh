# =============================================================================
# 🚀 Powerlevel10k - Starship "True Clone" Edition
# =============================================================================

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # 1. 布局顺序 (严格对标 Starship)
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context                 # SSH 逻辑
    dir                     # 路径 (项目感知)
    vcs                     # Git 状态
    nix_shell               # Nix
    command_execution_time  # 耗时
    prompt_char             # ➜
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # 2. 全局扁平化样式
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

  # [Context] - 仅 SSH 显示
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION='' 
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND='214'
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n @ %m'
  typeset -g POWERLEVEL9K_CONTEXT_VISUAL_IDENTIFIER_EXPANSION=''

  # [Directory] - 路径修复 (彻底移除 ~/.config 前缀)
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='14' # Cyan
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='14'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  # ✅ 关键修正 1：禁止将家目录子目录视为根，允许项目切断逻辑生效
  typeset -g POWERLEVEL9K_DIR_HOME_SUBFOLDER_AS_ROOT=false
  # ✅ 关键修正 2：强制开启切断，并指定项目标记
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=true
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER='(.git|flake.nix|default.nix)'
  # ✅ 关键修正 3：禁用其他干扰缩写
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=0
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=''
  typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION=''

  # [VCS] - Git 状态 (移除圆圈，对标 Starship 符号)
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='13'    # Purple
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='13'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='13'
  
  # ✅ 关键修正 4：自定义 Git 状态显示，模仿 Starship 的简洁感
  # 移除 P10k 默认的圆圈符号，改用 Starship 风格
  typeset -g POWERLEVEL9K_VCS_COMMITS_AHEAD_THEN_BEHIND=true
  typeset -g POWERLEVEL9K_VCS_AHEAD_ICON='⇡'
  typeset -g POWERLEVEL9K_VCS_BEHIND_ICON='⇣'
  typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'
  typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='!'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  
  # 禁用 P10k 默认的 Git 格式化，使用我们自己的
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1))):-}'

  # [Character] - ➜
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND='green'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND='red'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='➜'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='✖'

  # [Command Duration] - took 25s (亮黄)
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='226' 
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX='took '

  # 4. 环境控制
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
}

# ✅ 关键修正 5：自定义 Git 格式化函数，确保符号紧跟分支名
function my_git_formatter() {
  emulate -L zsh
  if [[ -n $P9K_CONTENT ]]; then
    # 纯紫色显示分支名
    echo -n "%F{13} ${VCS_STATUS_LOCAL_BRANCH:-${VCS_STATUS_COMMIT:0:8}}%f"
    # 紧跟状态符号 (对标 Starship)
    (( VCS_STATUS_COMMITS_AHEAD )) && echo -n " %F{13}⇡${VCS_STATUS_COMMITS_AHEAD}%f"
    (( VCS_STATUS_COMMITS_BEHIND )) && echo -n " %F{13}⇣${VCS_STATUS_COMMITS_BEHIND}%f"
    (( VCS_STATUS_NUM_STAGED )) && echo -n " %F{11}+${VCS_STATUS_NUM_STAGED}%f"
    (( VCS_STATUS_NUM_UNSTAGED )) && echo -n " %F{9}!${VCS_STATUS_NUM_UNSTAGED}%f"
    (( VCS_STATUS_NUM_UNTRACKED )) && echo -n " %F{14}?${VCS_STATUS_NUM_UNTRACKED}%f"
  fi
}
