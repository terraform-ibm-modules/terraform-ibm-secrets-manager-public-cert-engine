provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = local.existing_secrets_manager_region
  visibility       = var.provider_visibility
}

provider "ibm" {
  alias            = "secret-store"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = local.existing_secrets_manager_region
  visibility       = var.provider_visibility
}
