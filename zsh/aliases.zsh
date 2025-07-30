# ===============================================================================
# ALIASES
# ===============================================================================

# ------------------------------
# General Aliases
# ------------------------------
alias whatis="alias | grep"
alias copilot="gh copilot explain"
alias copilot-help="gh copilot suggest"
alias history='fc -l 1'
alias rf='source ~/.zshrc'

# ------------------------------
# Git Aliases
# ------------------------------
alias glog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"

# ------------------------------
# Development Aliases
# ------------------------------
alias showcoverage="pnpm test:coverage:open"
alias newtranslation='pnpm translations:generate-index-files'

# ------------------------------
# Worktree Aliases (Conditional)
# ------------------------------
if [[ "$DOTFILES_EXTERNAL_FUNCTIONS" == "true" ]]; then
  alias dtree='devtree'
  alias dt='devtree'
  alias treels='dev tree list'
  alias treerm='dev tree remove'
  alias treestatus='tree_status'
  alias ts='tree_status'
fi
