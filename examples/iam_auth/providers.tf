provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

provider "ibm" {
  alias            = "secret-store"
  ibmcloud_api_key = local.ibmcloud_secret_store_api_key
  region           = var.private_key_secrets_manager_region
}
