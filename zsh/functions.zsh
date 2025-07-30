# ===============================================================================
# GENERAL FUNCTIONS
# ===============================================================================

# ------------------------------
# Function Reload Utilities
# ------------------------------
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

  # Checkout the branch
  git checkout "$selected_branch"
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
        path="$1"
        shift
        ;;
    esac
  done

  if [ "$help_mode" = true ]; then
    echo "Usage: coverage [path] [options]"
    echo ""
    echo "Options:"
    echo "  -e, --extensions  File extensions to include (default: ts,tsx)"
    echo "  -h, --help        Show this help"
    echo "  --*               Pass additional arguments to test command"
    echo ""
    echo "Examples:"
    echo "  coverage                              # Full coverage"
    echo "  coverage src/components              # Coverage for specific path"
    echo "  coverage -e js,jsx                   # Different extensions"
    echo "  coverage --watchAll=false            # Additional test args"
    return 0
  fi

  # Default to current directory if no path provided
  if [ -z "$path" ]; then
    path="."
  fi

  # Build coverage pattern
  local coverage_pattern="**/*{${extensions}}"
  echo "Running coverage for: $path"
  echo "Extensions: $extensions"
  echo "Pattern: $coverage_pattern"

  # Detect package manager
  local package_manager
  if [ -f "pnpm-lock.yaml" ]; then
    package_manager="pnpm"
  elif [ -f "yarn.lock" ]; then
    package_manager="yarn"
  else
    package_manager="npm"
  fi

  echo "Using package manager: $package_manager"

  # Run the coverage command
  $package_manager test:coverage "$path" --collectCoverageFrom="$coverage_pattern" $extra_args
}
