provider "ibm" {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = local.existing_secrets_manager_region
  visibility            = var.provider_visibility
  private_endpoint_type = (var.provider_visibility == "private" && local.existing_secrets_manager_region == "ca-mon") ? "vpe" : null
}

provider "ibm" {
  alias            = "secret-store"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = local.existing_secrets_manager_region
  visibility       = var.provider_visibility
}
