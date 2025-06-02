# ===============================================================================
# ZSH CONFIGURATION
# ===============================================================================

# ------------------------------
# Performance & Shell Options (Industry Standard)
# ------------------------------
# Enable better error handling
setopt EXTENDED_GLOB
setopt GLOB_DOTS
setopt NO_CASE_GLOB
setopt NUMERIC_GLOB_SORT

# History settings (Industry Standard)
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP
setopt SHARE_HISTORY

# Performance settings
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# ------------------------------
# Environment Detection (Industry Standard)
# ------------------------------
# Detect OS and architecture
export DOTFILES_OS="$(uname -s)"
export DOTFILES_ARCH="$(uname -m)"

# Set platform-specific variables
case "$DOTFILES_OS" in
  Darwin)
    export DOTFILES_PLATFORM="macos"
    export DOTFILES_HOMEBREW_PREFIX="/opt/homebrew"
    [[ "$DOTFILES_ARCH" == "x86_64" ]] && export DOTFILES_HOMEBREW_PREFIX="/usr/local"
    ;;
  Linux)
    export DOTFILES_PLATFORM="linux"
    ;;
  *)
    export DOTFILES_PLATFORM="unknown"
    ;;
esac

# ------------------------------
# Oh-My-Zsh Configuration
# ------------------------------
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="af-magic"
DISABLE_CORRECTION="true"

# ------------------------------
# History Configuration (Industry Standard)
# ------------------------------
HISTFILE=~/.data/cartridges/history/.zhistory
HISTSIZE=50000
SAVEHIST=50000

# ------------------------------
# Plugins
# ------------------------------
plugins=(git macos z history zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ===============================================================================
# ENVIRONMENT SETUP
# ===============================================================================

# ------------------------------
# Environment Variables
# ------------------------------
export GPG_TTY=$(tty)

# ------------------------------
# Lazy Loading Functions (Industry Standard)
# ------------------------------
# Lazy load Homebrew (only when needed)
_lazy_load_brew() {
  if [[ -x "$DOTFILES_HOMEBREW_PREFIX/bin/brew" ]]; then
    eval "$($DOTFILES_HOMEBREW_PREFIX/bin/brew shellenv)"
  fi
}

# Lazy load FZF (only when needed)
_lazy_load_fzf() {
  if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"

    # FZF with fd integration
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

    # Use fd for listing path candidates
    _fzf_compgen_path() {
      fd --hidden --exclude .git . "$1"
    }

    # Use fd to generate the list for directory completion
    _fzf_compgen_dir() {
      fd --type=d --hidden --exclude .git . "$1"
    }
  fi
}

# Lazy load Starship (only when needed for prompt)
_lazy_load_starship() {
  if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
  fi
}

# Override commands to trigger lazy loading
brew() {
  unfunction brew
  _lazy_load_brew
  brew "$@"
}

fzf() {
  unfunction fzf
  _lazy_load_fzf
  fzf "$@"
}

# Load essential tools immediately
_lazy_load_starship

# ------------------------------
# External Tools and Sources (with Error Handling)
# ------------------------------
# Source external files safely
safe_source() {
  [[ -f "$1" ]] && source "$1"
}

safe_source /opt/dev/dev.sh
safe_source ~/fzf-git.sh/fzf-git.sh

# Load chruby safely
if [[ -f /opt/dev/sh/chruby/chruby.sh ]]; then
  if ! type chruby >/dev/null 2>&1; then
    chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; }
  fi
fi

# Helper function to check function availability
function dotfiles_status() {
  echo "🔧 Dotfiles Configuration Status"
  echo "================================="
  echo ""

  if [[ "$DOTFILES_EXTERNAL_FUNCTIONS" == "true" ]]; then
    echo "✅ External functions: LOADED from ~/.zsh/functions"
    echo "✅ Advanced aliases: ENABLED"
    echo ""
    echo "📁 Available external functions:"
    if [[ -d ~/.zsh/functions ]]; then
      for func in ~/.zsh/functions/*; do
        if [[ -f "$func" ]]; then
          echo "   • $(basename "$func")"
        fi
      done
    fi
  else
    echo "⚠️  External functions: FALLBACK MODE"
    echo "⚠️  Advanced aliases: DISABLED"
    echo ""
    echo "📝 Fallback functions available:"
    echo "   • devtree (basic dev tree commands)"
    echo "   • tree_status (basic git status)"
    echo "   • create_shop (basic shop creation)"
    echo "   • change_plan (basic plan change)"
    echo "   • billing_setup (shows manual commands)"
    echo "   • check_pr_shipped (basic PR status)"
    echo ""
    echo "🔧 To enable full functionality:"
    echo "   1. Ensure ~/.zsh/functions directory exists"
    echo "   2. Add your function files to that directory"
    echo "   3. Restart your shell or run: source ~/.zshrc"
  fi

  echo ""
  echo "🛠️  Dependencies:"
  if [[ "$DOTFILES_MISSING_DEPS" == "true" ]]; then
    echo "   ❌ Some dependencies missing (run check_dependencies)"
  else
    echo "   ✅ Dependencies OK"
  fi
}

# ------------------------------
# Dependency Management (Optimized)
# ------------------------------
# Check for required dependencies (cached)
check_dependencies() {
  # Use cache to avoid repeated checks
  local cache_file="/tmp/.dotfiles_deps_$(whoami)"
  local cache_ttl=3600  # 1 hour

  if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_ttl ]]; then
    return 0
  fi

  local missing_deps=()

  # Check for gum
  if ! command -v gum >/dev/null 2>&1; then
    missing_deps+=("gum")
  fi

  # Check for other critical dependencies
  if ! command -v fzf >/dev/null 2>&1; then
    missing_deps+=("fzf")
  fi

  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "⚠️  Missing dependencies: ${missing_deps[*]}"
    echo "📝 Install them with:"

    if command -v brew >/dev/null 2>&1; then
      echo "   brew install ${missing_deps[*]}"
    elif command -v apt-get >/dev/null 2>&1; then
      echo "   sudo apt-get install ${missing_deps[*]}"
    else
      echo "   Please install manually: ${missing_deps[*]}"
    fi

    echo "🔧 Or run: ./setup.sh to install automatically"
    return 1
  fi

  # Cache successful check
  touch "$cache_file"
  return 0
}

# Smart dependency check (only in interactive shells)
if [[ $- == *i* ]]; then
  # Check dependencies once per session (not per shell)
  if [[ -z "$DOTFILES_DEPS_CHECKED" ]]; then
    if check_dependencies >/dev/null 2>&1; then
      export DOTFILES_MISSING_DEPS=false
    else
      export DOTFILES_MISSING_DEPS=true
    fi
    export DOTFILES_DEPS_CHECKED=true
  fi
fi

# Smart gum wrapper - graceful degradation
smart_gum() {
  if ! command -v gum >/dev/null 2>&1; then
    if [[ "$DOTFILES_MISSING_DEPS" == "true" ]]; then
      echo "❌ gum is required for interactive functions"
      echo "🔧 Run: check_dependencies to see installation instructions"
      return 1
    fi
  fi
  command gum "$@"
}

# Utility function to check and install dependencies
install_deps() {
  if check_dependencies; then
    echo "✅ All dependencies are installed!"
    return 0
  fi

  echo "📦 Installing missing dependencies..."

  if command -v brew >/dev/null 2>&1; then
    if ! command -v gum >/dev/null 2>&1; then
      echo "Installing gum..."
      brew install gum
    fi
    if ! command -v fzf >/dev/null 2>&1; then
      echo "Installing fzf..."
      brew install fzf
    fi
  else
    echo "❌ Automatic installation requires Homebrew"
    echo "🔧 Run ./setup.sh or install manually"
    return 1
  fi

  echo "✅ Dependencies installed successfully!"
  # Clear cache
  rm -f "/tmp/.dotfiles_deps_$(whoami)"
}

# ------------------------------
# PATH Management (Industry Standard)
# ------------------------------
# Function to add to PATH only if not already present
add_to_path() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

# Add paths in order of priority
add_to_path "$HOME/.console-ninja/.bin"
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/bin"

# Export PATH
export PATH

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

# ------------------------------
# Git Aliases
# ------------------------------
alias glog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"

# ------------------------------
# Development Aliases
# ------------------------------
alias showcoverage="pnpm test:coverage:open"
alias newtranslation='pnpm translations:generate-index-files'

# Worktree aliases (conditional on external functions)
if [[ "$DOTFILES_EXTERNAL_FUNCTIONS" == "true" ]]; then
  alias dtree='devtree'
  alias dt='devtree'
  alias treels='dev tree list'
  alias treerm='dev tree remove'
  alias treestatus='tree_status'
  alias ts='tree_status'
fi

# ===============================================================================
# FUNCTIONS
# ===============================================================================

# ------------------------------
# General Utility Functions
# ------------------------------
npm-latest () { npm info "$1" | grep latest; } # check latest

# ------------------------------
# Git Functions
# ------------------------------
checkout () {
  # If arguments provided, use traditional checkout
  if [ $# -gt 0 ]; then
    git checkout "$@"
    return
  fi

  # Interactive branch selection
  local branches=$(git branch -a --format='%(refname:short)' | grep -v HEAD | sort -u)

  if [ -z "$branches" ]; then
    smart_gum style --foreground 196 "❌ No branches found"
    return 1
  fi

  local selected_branch=$(echo "$branches" | smart_gum choose --header "🌿 Select branch to checkout:")

  if [ -z "$selected_branch" ]; then
    smart_gum style --foreground 196 "❌ No branch selected"
    return 1
  fi

  # Remove origin/ prefix if present
  selected_branch=${selected_branch#origin/}

  smart_gum style --foreground 212 "🔄 Checking out: $selected_branch"
  git checkout "$selected_branch"
}

newbranch () { git checkout -b "$@"; }
renamebranch () { git branch -m "$@"; }
fetch () { git fetch origin $1; }
pull () { git pull origin $1; }
reset () { git reset --hard origin/$1; }
rebase () {
  git fetch origin $1
  git rebase origin/$1
}

# ------------------------------
# Development Functions (conditional loading with fallbacks)
# ------------------------------
if [[ "$DOTFILES_EXTERNAL_FUNCTIONS" != "true" ]]; then
  # Fallback implementations when external functions are not available

  devtree() {
    echo "⚠️  devtree: External function not available"
    echo "📝 Fallback: Using basic dev tree commands"
    if command -v dev >/dev/null 2>&1; then
      dev tree "$@"
    else
      echo "❌ 'dev' command not found. Install dev tools or add ~/.zsh/functions"
    fi
  }

  tree_status() {
    echo "⚠️  tree_status: External function not available"
    echo "📝 Fallback: Showing basic git status"
    if git rev-parse --git-dir >/dev/null 2>&1; then
      echo "📁 Current directory: $(pwd)"
      echo "🌿 Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
      git status --short
    else
      echo "❌ Not in a git repository"
    fi
  }
fi

# ------------------------------
# Testing Functions
# ------------------------------
function coverage() {
  local path=""
  local extensions="ts,tsx"
  local extra_args=""
  local help_mode=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -e|--extensions)
        extensions="$2"
        shift 2
        ;;
      -h|--help)
        help_mode=true
        shift
        ;;
      --*)
        extra_args="$extra_args $1"
        shift
        ;;
      *)
        if [ -z "$path" ]; then
          path="$1"
        else
          extra_args="$extra_args $1"
        fi
        shift
        ;;
    esac
  done

  # Show help
  if [ "$help_mode" = true ] || [ -z "$path" ]; then
    echo "Usage: coverage PATH [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --extensions EXT    File extensions to include (default: ts,tsx)"
    echo "  -h, --help             Show this help message"
    echo "  --*                    Pass additional arguments to pnpm test:coverage"
    echo ""
    echo "Examples:"
    echo "  coverage app/foundation/Frame"
    echo "  coverage app/components -e js,jsx,ts,tsx"
    echo "  coverage src --watchAll=false --verbose"
    echo "  coverage tests -e spec.ts,test.ts --silent"
    return 1
  fi

  # Detect package manager
  local package_manager=""
  if command -v pnpm >/dev/null 2>&1; then
    package_manager="pnpm"
  elif [ -f "$HOME/.dev/pnpm/8.15.5/pnpm" ]; then
    package_manager="$HOME/.dev/pnpm/8.15.5/pnpm"
  elif command -v npm >/dev/null 2>&1; then
    package_manager="npm run"
  elif command -v yarn >/dev/null 2>&1; then
    package_manager="yarn"
  else
    echo "Error: No package manager found (pnpm, npm, or yarn)"
    return 1
  fi

  # Build the collectCoverageFrom pattern
  local coverage_pattern="$path/**/*.{$extensions}"

  echo "Running coverage for: $path"
  echo "File extensions: $extensions"
  echo "Coverage pattern: $coverage_pattern"
  echo "Using package manager: $package_manager"

  # Run the coverage command
  $package_manager test:coverage "$path" --collectCoverageFrom="$coverage_pattern" $extra_args
}

# ------------------------------
# PR Management Functions (conditional loading with fallbacks)
# ------------------------------
if [[ "$DOTFILES_EXTERNAL_FUNCTIONS" != "true" ]]; then
  check_pr_shipped() {
    echo "⚠️  check_pr_shipped: External function not available"
    echo "📝 Fallback: Use 'gh pr status' or check GitHub manually"
    if command -v gh >/dev/null 2>&1; then
      echo "🔍 Showing PR status for current repository:"
      gh pr status
    else
      echo "❌ 'gh' command not found. Install GitHub CLI or add ~/.zsh/functions"
    fi
  }
fi

# ------------------------------
# Shop Management Functions (conditional loading with fallbacks)
# ------------------------------
if [[ "$DOTFILES_EXTERNAL_FUNCTIONS" != "true" ]]; then
  create_shop() {
    echo "⚠️  create_shop: External function not available"
    echo "📝 Fallback: Use bin/rails dev:shop:create manually"
    echo "💡 Example: bin/rails dev:shop:create SHOP_DOMAIN=myshop.myshopify.com"
    if [[ $# -gt 0 ]]; then
      echo "🔄 Attempting basic shop creation with provided arguments..."
      bin/rails dev:shop:create "$@"
    fi
  }

  change_plan() {
    echo "⚠️  change_plan: External function not available"
    echo "📝 Fallback: Use bin/rails dev:shop:change_plan manually"
    if [[ $# -ge 2 ]]; then
      echo "🔄 Attempting plan change: SHOP_ID=$1 PLAN=$2"
      bin/rails dev:shop:change_plan SHOP_ID="$1" PLAN="$2"
    else
      echo "💡 Usage: change_plan SHOP_ID PLAN"
      echo "💡 Example: change_plan 12345 plus"
    fi
  }
fi

function freeze_shop() { bin/rails dev:shop:change_plan SHOP_ID="$1" PLAN=frozen; }

# ------------------------------
# Billing Functions (conditional loading with fallbacks)
# ------------------------------
if [[ "$DOTFILES_EXTERNAL_FUNCTIONS" != "true" ]]; then
  billing_setup() {
    echo "⚠️  billing_setup: External function not available"
    echo "📝 Fallback: Use bin/rails dev:billing commands manually"
    if [[ -n "$1" ]]; then
      echo "🏪 Shop ID: $1"
      echo "💡 Available commands:"
      echo "   bin/rails dev:billing:add_invoices SHOP_ID=$1"
      echo "   bin/rails dev:billing:add_failed_invoice SHOP_ID=$1"
      echo "   bin/rails dev:billing:add_payment_method SHOP_ID=$1 TYPE=credit_card"
    else
      echo "💡 Usage: billing_setup SHOP_ID"
      echo "💡 Example: billing_setup 12345"
    fi
  }
fi

# Legacy functions (for backwards compatibility)
function invoices() { billing_setup "$1"; }
function failed_invoice() { billing_setup "$1"; }
function onetime_invoice() { billing_setup "$1"; }
function domaininvoice() { billing_setup "$1"; }
function themeinvoice() { billing_setup "$1"; }
function addcc() { billing_setup "$1"; }
function addpaypal() { billing_setup "$1"; }
function addupi() { billing_setup "$1"; }
function addbank() { billing_setup "$1"; }

# ------------------------------
# App Management Functions
# ------------------------------
function newapp() {
  local shop_id="$1"
  local app_handle="$2"
  local access_token="${3:-$(openssl rand -hex 16)}"

  if [[ -z "$shop_id" || -z "$app_handle" ]]; then
    echo "Usage: newapp SHOP_ID APP_HANDLE [ACCESS_TOKEN]"
    echo "Example: newapp 12345 my-app"
    return 1
  fi

  bin/rake dev:create_app_permission SHOP_ID="$shop_id" APP_HANDLE="$app_handle" ACCESS_TOKEN="$access_token"
}

# ===============================================================================
# TOOL INTEGRATIONS
# ===============================================================================

# ------------------------------
# Function Loading (Industry Standard)
# ------------------------------
# Check if functions directory exists and load conditionally
if [[ -d ~/.zsh/functions ]]; then
  # Add function path for autoload support
  fpath=(~/.zsh/functions $fpath)

  # Autoload individual function files (lazy loading)
  autoload -Uz ~/.zsh/functions/[^_]*(@) 2>/dev/null

  # Set flag for conditional alias loading
  export DOTFILES_EXTERNAL_FUNCTIONS=true
else
  export DOTFILES_EXTERNAL_FUNCTIONS=false

  # Show one-time warning (cached per session)
  if [[ -z "$DOTFILES_FUNCTIONS_WARNING_SHOWN" && $- == *i* ]]; then
    echo "⚠️  External functions directory (~/.zsh/functions) not found"
    echo "📝 Some advanced functions will use fallback implementations"
    echo "🔧 To get full functionality, ensure ~/.zsh/functions exists"
    export DOTFILES_FUNCTIONS_WARNING_SHOWN=true
  fi
fi

# ------------------------------
# Completion System (Industry Standard)
# ------------------------------
# Enable completion system
autoload -Uz compinit

# Security: check for insecure directories
if [[ $DOTFILES_PLATFORM == "macos" ]]; then
  # macOS: check once per day
  if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
  else
    compinit -C
  fi
else
  # Linux: always check
  compinit
fi

# Better completion for common commands (lazy loaded)
_load_completions() {
  if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion zsh)
  fi

  if command -v docker >/dev/null 2>&1; then
    source <(docker completion zsh)
  fi
}

# Load completions in background to avoid blocking startup
if [[ $- == *i* ]]; then
  _load_completions &!
fi

# ------------------------------
# Security Settings (Industry Standard)
# ------------------------------
# Disable command not found handler for security
unsetopt CORRECT_ALL
setopt CORRECT

# Secure umask
umask 022

# ------------------------------
# Performance Monitoring
# ------------------------------
# Function to time shell startup
time_startup() {
  for i in {1..5}; do
    time zsh -i -c exit
  done
}

[[ -f /opt/dev/sh/chruby/chruby.sh ]] && { type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; } }
