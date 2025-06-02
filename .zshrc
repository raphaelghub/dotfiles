# ------------------------------
# Path to your oh-my-zsh configuration
# ------------------------------
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="af-magic"

# Uncomment following line if you want to disable command autocorrection
DISABLE_CORRECTION="true"

# ------------------------------
# History Configuration
# ------------------------------
# HIST_STAMPS="mm/dd/yyyy"
HISTFILE=~/.data/cartridges/history/.zhistory

# ------------------------------
# Plugins
# ------------------------------
# Which plugins would you like to load?
# (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(git macos z history zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ------------------------------
# Environment Variables and Sourcing
# ------------------------------
set -k

[ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh
[[ -x /usr/local/bin/brew ]] && eval $(/usr/local/bin/brew shellenv)
[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

fpath=(~/.zsh/functions $fpath)
autoload -Uz ~/.zsh/functions/[^_]*(@)

# ------------------------------
# Aliases
# ------------------------------
# General
alias whatis="alias | grep"
alias copilot="gh copilot explain"
alias copilot-help="gh copilot suggest"
alias history='fc -l 1'

# Git
alias glog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"

# ------------------------------
# Functions
# ------------------------------
# General Functions
npm-latest () { npm info "$1" | grep latest; } # check latest
killport () { lsof -i tcp:"$*" | awk 'NR!=1 {print $2}' | xargs kill -9 ;} # kill port

# Development Functions
function devtree() {
  local branch=${1:-review-branch}
  local domain=${2:-clients/admin-web}
  dev cd +$branch//areas/$domain
}

checkout () { git checkout "$@"; }
isitdeployed () { dev conveyor is-it-shipped "$1"; }
newbranch () { git checkout -b "$@"; }
renamebranch () { git branch -m "$@"; }
fetch () { git fetch origin $1; }
pull () { git pull origin $1; }
reset () { git reset --hard origin/$1; }
rebase () {
  git fetch origin $1
  git rebase origin/$1
}

# Shop Management Functions
alias usshop='bin/rails dev:shop:create COUNTRY=US API_CLIENT_HANDLES=facebook,online_store'
alias inrshop='bin/rails dev:shop:create COUNTRY=IN API_CLIENT_HANDLES=facebook,online_store'
alias eushop='bin/rails dev:shop:create PLAN=basic API_CLIENT_HANDLES=facebook,online_store COUNTRY=DE'
alias newtranslation='pnpm translations:generate-index-files'

function freeze_shop() { bin/rails dev:shop:change_plan SHOP_ID="$1" PLAN=frozen; }
function change_plan() { bin/rails dev:shop:change_plan SHOP_ID="$1" PLAN="$2"; }

# Billing Functions
function invoices() { bin/rails seed:invoice:all SHOP_ID="$1"; }
function failed_invoice() { bin/rails seed:invoice:create_failed_invoice SHOP_ID="$1"; }
function onetime_invoice() { bin/rails seed:invoice:one_time SHOP_ID="$1"; }
function domaininvoice() { bin/rails seed:invoice:domain SHOP_ID="$1"; }
function themeinvoice() { bin/rails seed:invoice:theme SHOP_ID="$1"; }
function addcc() { bin/rails seed:payment_methods:credit_card SHOP_ID="$1"; }
function addpaypal() { bin/rails seed:payment_methods:paypal SHOP_ID="$1"; }
function addupi() { bin/rails seed:payment_methods:upi SHOP_ID="$1"; }
function addbank() { bin/rails seed:payment_methods:bank_account SHOP_ID="$1"; }

# App Management Function
function newapp() { bin/rake dev:create_app_permission SHOP_ID="$1" APP_HANDLE="$2" ACCESS_TOKEN=abc123; }

# ------------------------------
# Additional Configuration
# ------------------------------
[[ -f /opt/dev/sh/chruby/chruby.sh ]] && { type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; } }
export GPG_TTY=$(tty)

# ------------------------------
# PATH Configuration
# ------------------------------
PATH=~/.console-ninja/.bin:$PATH

eval "$(starship init zsh)"
eval "$(fzf --zsh)"


# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}


source ~/fzf-git.sh/fzf-git.sh
