# ===============================================================================
# ZSH CONFIGURATION - MODULAR & ORGANIZED
# ===============================================================================

# ------------------------------
# Performance & Shell Options
# ------------------------------
setopt EXTENDED_GLOB GLOB_DOTS NO_CASE_GLOB NUMERIC_GLOB_SORT
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS HIST_BEEP SHARE_HISTORY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT

# ------------------------------
# Environment Detection
# ------------------------------
export DOTFILES_OS="$(uname -s)"
export DOTFILES_ARCH="$(uname -m)"

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
plugins=(git macos z history zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# ------------------------------
# History Configuration
# ------------------------------
HISTFILE=~/.data/cartridges/history/.zhistory
HISTSIZE=50000
SAVEHIST=50000

# ------------------------------
# Environment Variables
# ------------------------------
export GPG_TTY=$(tty)

# ------------------------------
# Tool Integration
# ------------------------------
# Load Homebrew
if [[ -x "$DOTFILES_HOMEBREW_PREFIX/bin/brew" ]]; then
  eval "$($DOTFILES_HOMEBREW_PREFIX/bin/brew shellenv)"
fi

# Load FZF
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
  export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

  _fzf_compgen_path() { fd --hidden --exclude .git . "$1"; }
  _fzf_compgen_dir() { fd --type=d --hidden --exclude .git . "$1"; }
fi

# Load Starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ------------------------------
# PATH Management
# ------------------------------
path_prepend() {
  [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
}

path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.console-ninja/.bin"
path_prepend "$HOME/.dev/userprofile/bin"
path_prepend "/opt/dev/bin/user"

# ===============================================================================
# MODULAR CONFIGURATION LOADING
# ===============================================================================

DOTFILES_DIR="$HOME/Documents/dotfiles"

# Source modular config files
[[ -f "$DOTFILES_DIR/zsh/aliases.zsh" ]] && source "$DOTFILES_DIR/zsh/aliases.zsh"
[[ -f "$DOTFILES_DIR/zsh/functions.zsh" ]] && source "$DOTFILES_DIR/zsh/functions.zsh"

# Source environment-specific configs
[[ -f "$DOTFILES_DIR/zsh/shopify.zsh" ]] && command -v dev >/dev/null 2>&1 && source "$DOTFILES_DIR/zsh/shopify.zsh"

# ===============================================================================
# DEVTREE FUNCTION (Embedded for Zero Caching)
# ===============================================================================
devtree() {
  local action="" zone="" tree=""

  # Parse arguments for direct usage
  while [[ $# -gt 0 ]]; do
    case $1 in
      list|ls) dev tree list; return ;;
      remove|rm)
        shift
        local force_flag="" worktree_identifier=""
        while [[ $# -gt 0 ]]; do
          case $1 in
            --force) force_flag="--force"; shift ;;
            *) worktree_identifier="$1"; shift ;;
          esac
        done

        if [ -n "$worktree_identifier" ]; then
          gum style --foreground 214 "🗑️ Removing worktree: $worktree_identifier"
          dev tree remove "$worktree_identifier" $force_flag
        else
          local trees=$(dev tree list 2>/dev/null | grep -v "Available trees:" | grep -v "^$")
          if [ -n "$trees" ]; then
            local tree_to_remove=$(echo "$trees" | gum choose --header "🗑️ Select tree to remove:")
            if [ -n "$tree_to_remove" ]; then
              local clean_tree_name=$(echo "$tree_to_remove" | sed 's/^[[:space:]]*\*[[:space:]]*//' | awk '{print $1}')
              local use_force=false
              if [ -z "$force_flag" ] && gum confirm "Force remove (even if dirty)?"; then
                force_flag="--force"
                use_force=true
              fi
              local confirm_msg="Remove tree '$clean_tree_name'"
              [ "$use_force" = true ] && confirm_msg="$confirm_msg (with --force)"
              gum confirm "$confirm_msg?" && dev tree remove "$clean_tree_name" $force_flag
            fi
          else
            gum style --foreground 196 "❌ No trees found to remove"
          fi
        fi
        return ;;
      -h|--help)
        echo "devtree - Enhanced wrapper for 'dev tree' with interactive features"
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
        return ;;
      *)
        [ -z "$zone" ] && zone="$1" || tree="$1"
        shift ;;
    esac
  done

  # Direct zone + tree usage
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

  [ -z "$operation" ] && { gum style --foreground 196 "❌ No operation selected"; return 1; }

  case "$operation" in
    "🌳 Create new worktree")
      local zones_dir="$HOME/world/trees/root/src/areas"
      local zones=()

      if [ -d "$zones_dir" ]; then
        while IFS= read -r zone_path; do
          zones+=("${zone_path##*/}")
        done < <(find "$zones_dir" -type d -mindepth 1 -maxdepth 2 | sed 's|.*/src/areas/||' | grep -v '^\.' | sort)
      fi

      [ ${#zones[@]} -eq 0 ] && zones=("admin-web" "shopify" "billing" "organizations")

      local selected_zone=$(printf '%s\n' "${zones[@]}" | gum choose --header "🎯 Select zone:")
      [ -z "$selected_zone" ] && { gum style --foreground 196 "❌ No zone selected"; return 1; }

      local tree_name=$(gum input --placeholder "Enter tree name (e.g., feature-branch, bug-fix)" --header "🌿 Tree name:")
      [ -z "$tree_name" ] && { gum style --foreground 196 "❌ Tree name is required"; return 1; }

      gum style --border normal --margin "1" --padding "1" --border-foreground 212 \
        "🌳 Creating new worktree:" "Zone: $selected_zone" "Tree: $tree_name" "" "Command: dev cd $selected_zone -t $tree_name"

      gum confirm "Create worktree?" && dev cd "$selected_zone" -t "$tree_name" || gum style --foreground 196 "❌ Operation cancelled"
      ;;

    # ... (other cases similar pattern, shortened for brevity)

  esac
}

# ===============================================================================
# EXTERNAL FUNCTION LOADING
# ===============================================================================
if [[ -d ~/.zsh/functions ]]; then
  for func_file in ~/.zsh/functions/[^_]*; do
    if [[ -f "$func_file" ]]; then
      local func_name=$(basename "$func_file")
      [[ "$func_name" == "devtree" ]] && continue
      eval "${func_name}() { source ~/.zsh/functions/$func_name; }"
    fi
  done
  export DOTFILES_EXTERNAL_FUNCTIONS=true
else
  export DOTFILES_EXTERNAL_FUNCTIONS=false
fi

# ===============================================================================
# COMPLETION SYSTEM
# ===============================================================================
autoload -Uz compinit

if [[ $DOTFILES_PLATFORM == "macos" ]]; then
  [[ -n ~/.zcompdump(#qN.mh+24) ]] && compinit || compinit -C
else
  compinit
fi

# Load completions in background
_load_completions() {
  command -v kubectl >/dev/null 2>&1 && source <(kubectl completion zsh)
  command -v docker >/dev/null 2>&1 && source <(docker completion zsh)
}
[[ $- == *i* ]] && _load_completions &!

# ------------------------------
# Security & Performance
# ------------------------------
unsetopt CORRECT_ALL
setopt CORRECT
umask 022

# Performance monitoring
time_startup() {
  for i in {1..5}; do
    time zsh -i -c exit
  done
}

# ------------------------------
# Local Overrides
# ------------------------------
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ------------------------------
# Shopify Dev Tools (Conditional)
# ------------------------------
[[ -f /opt/dev/sh/chruby/chruby.sh ]] && {
  type chruby >/dev/null 2>&1 || chruby () {
    source /opt/dev/sh/chruby/chruby.sh;
    chruby "$@";
  }
}
