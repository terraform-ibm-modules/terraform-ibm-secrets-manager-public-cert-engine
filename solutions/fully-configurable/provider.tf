provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = local.existing_secrets_manager_region
}

provider "ibm" {
  alias            = "secret-store"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = local.existing_secrets_manager_region
}
