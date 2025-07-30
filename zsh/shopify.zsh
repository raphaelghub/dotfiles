# ===============================================================================
# SHOPIFY-SPECIFIC FUNCTIONS
# ===============================================================================
# These functions are only useful in Shopify development environments

# ------------------------------
# Shop Management
# ------------------------------
function freeze_shop() {
  bin/rails dev:shop:change_plan SHOP_ID="$1" PLAN=frozen;
}

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

# ------------------------------
# Legacy Billing Functions (Backwards Compatibility)
# ------------------------------
# Note: These all delegate to the main billing_setup function
function invoices() { billing_setup "$1"; }
function failed_invoice() { billing_setup "$1"; }
function onetime_invoice() { billing_setup "$1"; }
function domaininvoice() { billing_setup "$1"; }
function themeinvoice() { billing_setup "$1"; }
function addcc() { billing_setup "$1"; }
function addpaypal() { billing_setup "$1"; }
function addupi() { billing_setup "$1"; }
function addbank() { billing_setup "$1"; }
