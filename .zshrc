#!/bin/bash

# PROMPT
green=$(tput setaf 71);
yellow=$(tput setaf 3);
blue=$(tput setaf 45);
red=$(tput setaf 1);
bold=$(tput bold);
RESET=$(tput sgr0);

function git_branch {
  # Shows the current branch if in a git repository
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ \(\1\)/';
}

function random_element {
  declare -a array=("$@")
  r=$((RANDOM % ${#array[@]}))
  printf "%s\n" "${array[$r]}"
}

# Default Prompt
setEmoji () {
  EMOJI="$*"
  DISPLAY_DIR='$(dirs)'
  DISPLAY_BRANCH='$(git_branch)'
  if [ $SPIN ]; then
    PROMPT="${blue}${DISPLAY_DIR}${red}${bold}${DISPLAY_BRANCH}${RESET} 🌀"$'\n'"$ ";
  else
    PROMPT="${green}${DISPLAY_DIR}${yellow}${bold}${DISPLAY_BRANCH}${RESET} ${EMOJI}"$'\n'"$ ";
  fi
}

newRandomEmoji () {
  setEmoji "$(random_element 😅 🤖 🐙 💥 🚀) "
}

newRandomEmoji

# allow substitution in PS1
setopt promptsubst


# -------
# Aliases
# -------

# Git
alias gforce="git push --force-with-lease";
alias gcl="git checkout .";

commit () { git commit -m "$@"; }
checkout () { git checkout "$@"; }
newbranch () { git checkout -b "$@"; }
renamebranch () { git branch -m "$@"; }
fetch () {git fetch origin $1}
pull () {git pull origin $1}
pushto () {git push --force-with-lease origin $1 }
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


# General
md () { mkdir "$@" && cd "$@" || exit; } # make directory and enter directory
npm-latest () { npm info "$1" | grep latest; } # check latest
killport () { lsof -i tcp:"$*" | awk 'NR!=1 {print $2}' | xargs kill -9 ;} # kill port


# Spin
alias whatinstance="spin show -o fqdn --latest"
alias whatport="echo $MYSQL_PORT"
alias attachcore="journalctl --unit 'proc-shopify--shopify@server.service' --follow"
alias jc="journalctl"
alias attachbilling="journalctl --unit 'proc-shopify--billing@server.service' --follow"
alias attachweb="journalctl --unit 'proc-shopify--web@server.service' --follow"
alias stopcore="iso procs stop shopify--shopify"
alias stopweb="iso procs stop shopify--web"
function attach() { journalctl --unit "proc-shopify--'$1'" --follow }
alias whatfailed="systemctl list-units --failed"
alias refresh="yarn refresh-graphql"

alias spl="spin shell";
alias usshop='bin/rails dev:shop:create COUNTRY=US'
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

# Billing
function invoices() { bin/rails billing:invoice:all SHOP_ID="$1"; }
function failed_invoice() { bin/rails billing:invoice:create_failed_invoice SHOP_ID="$1"; }
function onetime_invoice() { bin/rails billing:invoice:one_time SHOP_ID="$1"; }
function domaininvoice() { bin/rails billing:invoice:domain SHOP_ID="$1"; }
function themeinvoice() { bin/rails billing:invoice:theme SHOP_ID="$1"; }

function addcc() { bin/rails billing:payment_methods:credit_card SHOP_ID="$1"; }
function addbank() { bin/rails billing:payment_methods:bank_account SHOP_ID="$1"; }

#port dev c  -> ActiveRecord::Base.connection_config[:port]

# Charges
function newtheme() { rake dev:edges:create:theme_charge SHOP_ID="$1"; }
function recurringcharge() { rails dev:edges:create:recurring_charge SHOP_ID="$1"; }

# Apps
function newapp() { bin/rake dev:create_app_permission SHOP_ID="$1" APP_HANDLE="$2" ACCESS_TOKEN=abc123; }
# ApiClient.where(handle: "my-app")[0].beta.enable('app_spending_limits')

