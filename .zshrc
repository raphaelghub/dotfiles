# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

ZSH_THEME="af-magic"

# Uncomment following line if you want to disable command autocorrection
DISABLE_CORRECTION="true"


# HIST_STAMPS="mm/dd/yyyy"
# commit-history to commit
HISTFILE=~/.data/cartridges/history/.zhistory


# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins#tmux
plugins=(git macos z history zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

set -k


[ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh

[[ -x /usr/local/bin/brew ]] && eval $(/usr/local/bin/brew shellenv)

[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)



# -------
# Aliases
# -------
alias whatis="alias | grep"

# General
npm-latest () { npm info "$1" | grep latest; } # check latest
killport () { lsof -i tcp:"$*" | awk 'NR!=1 {print $2}' | xargs kill -9 ;} # kill port
alias history='fc -l 1'

# Git
alias glog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"


checkout () { git checkout "$@"; }
newbranch () { git checkout -b "$@"; }
renamebranch () { git branch -m "$@"; }
fetch () {git fetch origin $1}
pull () {git pull origin $1}
reset () {git reset --hard origin/$1 }
rebase () {
  git fetch origin $1
  git rebase origin/$1
}
irebase () {
  git fetch origin $1
  git rebase -i origin/$1
}
irebasecount () {
  git rebase -i HEAD~$1
}


# Spin
alias whatinstance="spin show -o fqdn --latest"
alias whatport="echo $MYSQL_PORT"
alias attachcore="journalctl --unit 'proc-shopify--shopify@server.service' --follow"
alias watchspin="watch systemctl status"
alias jc="journalctl"
alias attachbilling="journalctl --unit 'proc-shopify--billing@server.service' --follow"
alias attachweb="journalctl --unit 'proc-shopify--web@server.service' --follow"
alias stopcore="iso procs stop shopify--shopify"
alias stopweb="iso procs stop shopify--web"
function attach() { journalctl --unit "proc-shopify--'$1'" --follow }
alias whatfailed="systemctl list-units --failed"
alias refresh="yarn refresh-graphql"

alias spl="spin shell";
function spd() { spin destroy "$1" }
function su() {
  spin up $1 --wait -c $1.branch=${2:-main}
}
function sunc() {
  spin up $1 --no-snapshots --wait -c $1.branch=${2:-main}
}
alias usshop='bin/rails dev:shop:create COUNTRY=US'
alias bshops='bin/rails business_platform:create SHOP_COUNTRIES=CA,CA'
alias inrshop='bin/rails dev:shop:create COUNTRY=IN'
alias eushop='bin/rails dev:shop:create PLAN=basic GATEWAY=bogus API_CLIENT_HANDLES=facebook,online_store COUNTRY=DE'
function freeze_shop() { bin/rails dev:shop:change_plan SHOP_ID="$1" PLAN=frozen; }
function change_plan() { bin/rails dev:shop:change_plan SHOP_ID="$1" PLAN="$2"; }
function shopify_payments() { bundle exec rake dev:shopify_payments:setup SHOP_ID="$1"; }
function internal() { open "https://app.$(spin info fqdn)/services/internal/shops/"$1"" }
function gql() { open "https://app.$(spin info fqdn)/services/internal/shops/"$1"/graphql" }
function spindb() { open "mysql://root@$(spin info fqdn):'$1'" }
function enable-beta() { bin/rails dev:betas:enable BETA="$1" SHOP_ID="$2"; }
function disable-beta() { bin/rails dev:betas:disable BETA="$1" SHOP_ID="$2"; }
function shop_user() { bin/rails dev:users:create SHOP_ID="$1"; }
alias commit-history='cart save history'

# Billing
function invoices() { bin/rails seed:invoice:all SHOP_ID="$1"; }
function failed_invoice() { bin/rails seed:invoice:create_failed_invoice SHOP_ID="$1"; }
function onetime_invoice() { bin/rails seed:invoice:one_time SHOP_ID="$1"; }
function domaininvoice() { bin/rails seed:invoice:domain SHOP_ID="$1"; }
function themeinvoice() { bin/rails seed:invoice:theme SHOP_ID="$1"; }

function addcc() { bin/rails seed:payment_methods:credit_card SHOP_ID="$1"; }
function addpaypal() { bin/rails seed:payment_methods:paypal SHOP_ID="$1"; }
function addupi() { bin/rails seed:payment_methods:upi SHOP_ID="$1"; }
function addbank() { bin/rails seed:payment_methods:bank_account SHOP_ID="$1"; }

#port dev c  -> ActiveRecord::Base.connection_config[:port]

# Charges
function newtheme() { rake dev:edges:create:theme_charge SHOP_ID="$1"; }
function recurringcharge() { rails dev:edges:create:recurring_charge SHOP_ID="$1"; }

# Apps
function newapp() { bin/rake dev:create_app_permission SHOP_ID="$1" APP_HANDLE="$2" ACCESS_TOKEN=abc123; }
# ApiClient.where(handle: "my-app")[0].beta.enable('app_spending_limits')


[[ -f /opt/dev/sh/chruby/chruby.sh ]] && type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; }
export GPG_TTY=$(tty)


# pkill -9 -f spring; pkill -9 -f 'rails.runner'; systemctl restart redis@shopify--shopify.service memcached@shopify--shopify.service mysql@shopify--shopify.service && restart shopify
