locals {
  # Certificate issuance is rate limited by domain, by default pick different domains to avoid rate limits during testing
  cert_common_name = var.cert_common_name == null ? "${var.prefix}.goldeneye.dev.cloud.ibm.com" : var.cert_common_name
}

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.7"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "secrets_manager" {
  source               = "terraform-ibm-modules/secrets-manager/ibm"
  version              = "2.12.25"
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  secrets_manager_name = "${var.prefix}-secrets-manager" #tfsec:ignore:general-secrets-no-plaintext-exposure
  sm_service_plan      = "trial"
  sm_tags              = var.resource_tags
}

# Best practise, use the secrets manager secret group module to create a secret group
module "secrets_manager_secret_group" {
  source                   = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version                  = "1.3.39"
  region                   = var.region
  secrets_manager_guid     = module.secrets_manager.secrets_manager_guid
  secret_group_name        = "${var.prefix}-certificates-secret-group"   #checkov:skip=CKV_SECRET_6: does not require high entropy string as is static value
  secret_group_description = "secret group used for public certificates" #tfsec:ignore:general-secrets-no-plaintext-exposure
}

locals {
  ibmcloud_secret_store_api_key = var.ibmcloud_secret_store_api_key == null ? var.ibmcloud_api_key : var.ibmcloud_secret_store_api_key
}

module "public_secret_engine" {
  source = "../.."
  providers = {
    ibm              = ibm
    ibm.secret-store = ibm.secret-store
  }
  secrets_manager_guid                      = module.secrets_manager.secrets_manager_guid
  region                                    = var.region
  internet_services_crn                     = var.cis_id
  dns_config_name                           = var.dns_provider_name
  ca_config_name                            = var.ca_name
  acme_letsencrypt_private_key              = var.acme_letsencrypt_private_key
  private_key_secrets_manager_instance_guid = var.private_key_secrets_manager_instance_guid
  private_key_secrets_manager_secret_id     = var.private_key_secrets_manager_secret_id
  private_key_secrets_manager_region        = var.private_key_secrets_manager_region
}

module "secrets_manager_public_certificate" {
  source     = "terraform-ibm-modules/secrets-manager-public-cert/ibm"
  version    = "1.5.25"
  depends_on = [module.public_secret_engine]

  cert_common_name      = local.cert_common_name
  cert_description      = "Certificate for ${local.cert_common_name} domain"
  cert_name             = "${var.prefix}-public-cert"
  cert_secrets_group_id = module.secrets_manager_secret_group.secret_group_id

  secrets_manager_ca_name           = var.ca_name
  secrets_manager_dns_provider_name = var.dns_provider_name

  secrets_manager_guid   = module.secrets_manager.secrets_manager_guid
  secrets_manager_region = var.region
}
