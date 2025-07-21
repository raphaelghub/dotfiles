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

# Function reload utilities
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
# Function Reload Utilities (Always Available)
# ------------------------------
# Alternative: Reload specific function by name
function reload() {
  if [[ -n "$1" && -f "$HOME/.zsh/functions/$1" ]]; then
    unfunction "$1" 2>/dev/null
    autoload -Uz "$1"
    echo "🔄 Reloaded function: $1"
  else
    echo "Usage: reload <function_name>"
    echo "Available functions:"
    ls ~/.zsh/functions/ 2>/dev/null | grep -v '^_' | head -10
  fi
}

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
    gum style --foreground 196 "❌ No branches found"
    return 1
  fi

  local selected_branch=$(echo "$branches" | gum choose --header "🌿 Select branch to checkout:")

  if [ -z "$selected_branch" ]; then
    gum style --foreground 196 "❌ No branch selected"
    return 1
  fi

  # Remove origin/ prefix if present
  selected_branch=${selected_branch#origin/}

  gum style --foreground 212 "🔄 Checking out: $selected_branch"
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





function freeze_shop() { bin/rails dev:shop:change_plan SHOP_ID="$1" PLAN=frozen; }



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
# Devtree Function (Directly Embedded - No Caching)
# ------------------------------
devtree() {
  local action=""
  local zone=""
  local tree=""

  # Parse arguments for direct usage
  while [[ $# -gt 0 ]]; do
    case $1 in
      list|ls)
        dev tree list
        return
        ;;
      remove|rm)
        shift  # Remove the 'remove' command from args
        local force_flag=""
        local worktree_identifier=""

        # Parse remove arguments
        while [[ $# -gt 0 ]]; do
          case $1 in
            --force)
              force_flag="--force"
              shift
              ;;
            *)
              worktree_identifier="$1"
              shift
              ;;
          esac
        done

        if [ -n "$worktree_identifier" ]; then
          # Direct removal with specified worktree
          gum style --foreground 214 "🗑️ Removing worktree: $worktree_identifier"
          dev tree remove "$worktree_identifier" $force_flag
        else
          # Interactive tree removal
          local trees=$(dev tree list 2>/dev/null | grep -v "Available trees:" | grep -v "^$")
          if [ -n "$trees" ]; then
            local tree_to_remove=$(echo "$trees" | gum choose --header "🗑️ Select tree to remove:")
            if [ -n "$tree_to_remove" ]; then
              # Extract just the tree name from the formatted output
              local clean_tree_name=$(echo "$tree_to_remove" | sed 's/^[[:space:]]*\*[[:space:]]*//' | awk '{print $1}')

              # Ask about force flag if not already set
              local use_force=false
              if [ -z "$force_flag" ]; then
                if gum confirm "Force remove (even if dirty)?"; then
                  force_flag="--force"
                  use_force=true
                fi
              fi

              local confirm_msg="Remove tree '$clean_tree_name'"
              if [ "$use_force" = true ]; then
                confirm_msg="$confirm_msg (with --force)"
              fi
              confirm_msg="$confirm_msg?"

              if gum confirm "$confirm_msg"; then
                dev tree remove "$clean_tree_name" $force_flag
              fi
            fi
          else
            gum style --foreground 196 "❌ No trees found to remove"
          fi
        fi
        return
        ;;
      -h|--help)
        echo "devtree - Enhanced wrapper for 'dev tree' with interactive features"
        echo ""
        echo "Manage worktrees. Support of worktrees outside of world is limited."
        echo ""
        echo "Usage: devtree [COMMAND] [OPTIONS]"
        echo ""
        echo "Commands:"
        echo "  list, ls                     List all worktrees within repo"
        echo "  remove, rm <identifier>      Remove a worktree by name or path"
        echo "    --force                    Force remove even if worktree is dirty"
        echo "  -h, --help                   Show this help"
        echo ""
        echo "Interactive mode (no arguments):"
        echo "  🌳 Create new worktree       Create and switch to new worktree"
        echo "  🔄 Switch to existing zone   Switch to zone with default tree (.)"
        echo "  🌿 Open existing tree        Open specific tree in selected zone"
        echo "  📋 List available trees      Show all worktrees"
        echo "  🗑️ Remove a tree            Interactive tree removal"
        echo ""
        echo "Examples:"
        echo "  devtree                         # Interactive mode"
        echo "  devtree list                   # List all trees"
        echo "  devtree remove my-tree         # Remove specific tree"
        echo "  devtree remove my-tree --force # Force remove dirty tree"
        echo "  devtree admin-web my-feature   # Direct: dev cd admin-web -t my-feature"
        echo ""
        echo "Interactive workflows:"
        echo "  🌿 'Open existing tree' → Select 'pr-review' → Select 'admin-web'"
        echo "     Result: dev cd admin-web -t pr-review"
        echo ""
        echo "Note: Support of worktrees outside of world is limited."
        return
        ;;
      *)
        # If two arguments provided, assume it's zone and tree
        if [ -z "$zone" ]; then
          zone="$1"
        elif [ -z "$tree" ]; then
          tree="$1"
        fi
        shift
        ;;
    esac
  done

  # If zone and tree provided directly
  if [ -n "$zone" ] && [ -n "$tree" ]; then
    dev cd "$zone" -t "$tree"
    return
  fi

  # Interactive mode
  local operation=$(gum choose \
    "🌳 Create new worktree" \
    "🔄 Switch to existing zone (default tree)" \
    "🌿 Open existing tree in zone" \
    "📋 List available trees" \
    "🗑️ Remove a tree" \
    --header "🏗️ Worktree Operations:")

  if [ -z "$operation" ]; then
    gum style --foreground 196 "❌ No operation selected"
    return 1
  fi

  case "$operation" in
    "🌳 Create new worktree")
      # Get available zones from areas directory
      local zones_dir="$HOME/world/trees/root/src/areas"
      local zones=()

      if [ -d "$zones_dir" ]; then
        while IFS= read -r zone_path; do
          # Extract just the zone name (part after the last slash)
          local zone_name="${zone_path##*/}"
          zones+=("$zone_name")
        done < <(find "$zones_dir" -type d -mindepth 1 -maxdepth 2 | sed 's|.*/src/areas/||' | grep -v '^\.' | sort)
      fi

      # Fallback zones if directory not found (use just zone names)
      if [ ${#zones[@]} -eq 0 ]; then
        zones=("admin-web" "shopify" "billing" "organizations")
      fi

      local selected_zone=$(printf '%s\n' "${zones[@]}" | gum choose --header "🎯 Select zone:")

      if [ -z "$selected_zone" ]; then
        gum style --foreground 196 "❌ No zone selected"
        return 1
      fi

      # Get tree name
      local tree_name=$(gum input --placeholder "Enter tree name (e.g., feature-branch, bug-fix)" --header "🌿 Tree name:")

      if [ -z "$tree_name" ]; then
        gum style --foreground 196 "❌ Tree name is required"
        return 1
      fi

      # Show what will be executed
      gum style \
        --border normal \
        --margin "1" \
        --padding "1" \
        --border-foreground 212 \
        "🌳 Creating new worktree:" \
        "Zone: $selected_zone" \
        "Tree: $tree_name" \
        "" \
        "Command: dev cd $selected_zone -t $tree_name"

      # Confirm and execute
      if gum confirm "Create worktree?"; then
        dev cd "$selected_zone" -t "$tree_name"
      else
        gum style --foreground 196 "❌ Operation cancelled"
      fi
      ;;

    "🔄 Switch to existing zone (default tree)")
      # Get available zones
      local zones_dir="$HOME/world/trees/root/src/areas"
      local zones=()

      if [ -d "$zones_dir" ]; then
        while IFS= read -r zone_path; do
          # Extract just the zone name (part after the last slash)
          local zone_name="${zone_path##*/}"
          zones+=("$zone_name")
        done < <(find "$zones_dir" -type d -mindepth 1 -maxdepth 2 | sed 's|.*/src/areas/||' | grep -v '^\.' | sort)
      fi

      if [ ${#zones[@]} -eq 0 ]; then
        zones=("admin-web" "shopify" "billing" "organizations")
      fi

      local selected_zone=$(printf '%s\n' "${zones[@]}" | gum choose --header "🎯 Select zone to switch to:")

      if [ -z "$selected_zone" ]; then
        gum style --foreground 196 "❌ No zone selected"
        return 1
      fi

      gum style \
        --border normal \
        --margin "1" \
        --padding "1" \
        --border-foreground 212 \
        "🔄 Switching to zone:" \
        "Zone: $selected_zone" \
        "" \
        "Command: dev cd $selected_zone -t ."

      dev cd "$selected_zone" -t .
      ;;

    "🌿 Open existing tree in zone")
      # First, get available trees
      local trees=$(dev tree list 2>/dev/null | grep -v "Available trees:" | grep -v "^$")

      if [ -z "$trees" ]; then
        gum style --foreground 196 "❌ No trees found"
        return 1
      fi

      local selected_tree=$(echo "$trees" | gum choose --header "🌿 Select tree to open:")

      if [ -z "$selected_tree" ]; then
        gum style --foreground 196 "❌ No tree selected"
        return 1
      fi

      # Extract just the tree name from the formatted output
      local clean_tree_name=$(echo "$selected_tree" | sed 's/^[[:space:]]*\*[[:space:]]*//' | awk '{print $1}')

      # Now get available zones
      local zones_dir="$HOME/world/trees/root/src/areas"
      local zones=()

      if [ -d "$zones_dir" ]; then
        while IFS= read -r zone_path; do
          # Extract just the zone name (part after the last slash)
          local zone_name="${zone_path##*/}"
          zones+=("$zone_name")
        done < <(find "$zones_dir" -type d -mindepth 1 -maxdepth 2 | sed 's|.*/src/areas/||' | grep -v '^\.' | sort)
      fi

      if [ ${#zones[@]} -eq 0 ]; then
        zones=("admin-web" "shopify" "billing" "organizations")
      fi

      local selected_zone=$(printf '%s\n' "${zones[@]}" | gum choose --header "🎯 Select zone to open tree '$clean_tree_name' in:")

      if [ -z "$selected_zone" ]; then
        gum style --foreground 196 "❌ No zone selected"
        return 1
      fi

      gum style \
        --border normal \
        --margin "1" \
        --padding "1" \
        --border-foreground 212 \
        "🌿 Opening existing tree in zone:" \
        "Tree: $clean_tree_name" \
        "Zone: $selected_zone" \
        "" \
        "Command: dev cd $selected_zone -t $clean_tree_name"

      dev cd "$selected_zone" -t "$clean_tree_name"
      ;;

    "📋 List available trees")
      gum style \
        --border normal \
        --margin "1" \
        --padding "1" \
        --border-foreground 212 \
        "📋 Available trees:"

      dev tree list
      ;;

    "🗑️ Remove a tree")
      local trees=$(dev tree list 2>/dev/null | grep -v "Available trees:" | grep -v "^$")

      if [ -z "$trees" ]; then
        gum style --foreground 196 "❌ No trees found to remove"
        return 1
      fi

      local tree_to_remove=$(echo "$trees" | gum choose --header "🗑️ Select tree to remove:")

      if [ -z "$tree_to_remove" ]; then
        gum style --foreground 196 "❌ No tree selected"
        return 1
      fi

      # Extract just the tree name from the formatted output
      # Remove leading/trailing whitespace and extract the tree name
      local clean_tree_name=$(echo "$tree_to_remove" | sed 's/^[[:space:]]*\*[[:space:]]*//' | awk '{print $1}')

      # Ask about force flag
      local force_flag=""
      local use_force=false
      if gum confirm "Force remove (even if dirty)?"; then
        force_flag="--force"
        use_force=true
      fi

      local command_text="dev tree remove $clean_tree_name"
      local confirm_msg="Remove tree '$clean_tree_name'"
      if [ "$use_force" = true ]; then
        command_text="$command_text --force"
        confirm_msg="$confirm_msg (with --force)"
      fi
      confirm_msg="$confirm_msg?"

      gum style \
        --border normal \
        --margin "1" \
        --padding "1" \
        --border-foreground 196 \
        "⚠️ About to remove tree:" \
        "Tree: $clean_tree_name" \
        "" \
        "Command: $command_text"

      if gum confirm "$confirm_msg"; then
        dev tree remove "$clean_tree_name" $force_flag
      else
        gum style --foreground 196 "❌ Operation cancelled"
      fi
      ;;
  esac
}

# ------------------------------
# Function Loading (ZERO CACHING - Always Current)
# ------------------------------
# Simple approach: source file every time it's called - absolutely no caching
if [[ -d ~/.zsh/functions ]]; then
  for func_file in ~/.zsh/functions/[^_]*; do
    if [[ -f "$func_file" ]]; then
      local func_name=$(basename "$func_file")
      # Skip devtree - it's defined directly in .zshrc
      if [[ "$func_name" == "devtree" ]]; then
        continue
      fi
      # Create simple wrapper that sources file every single call
      eval "${func_name}() { source ~/.zsh/functions/$func_name; }"
    fi
  done
  export DOTFILES_EXTERNAL_FUNCTIONS=true
else
  export DOTFILES_EXTERNAL_FUNCTIONS=false
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
