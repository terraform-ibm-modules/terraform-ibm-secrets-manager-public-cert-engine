locals {
  # Certificate issuance is rate limited by domain, by default pick different domains to avoid rate limits during testing
  cert_common_name = var.cert_common_name == null ? "${var.prefix}.goldeneye.dev.cloud.ibm.com" : var.cert_common_name
  sm_guid          = var.existing_sm_instance_crn == null ? module.secrets_manager[0].secrets_manager_guid : module.existing_sm_crn_parser[0].service_instance
  sm_region        = var.existing_sm_instance_crn == null ? var.region : module.existing_sm_crn_parser[0].region
}

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "existing_sm_crn_parser" {
  count   = var.existing_sm_instance_crn == null ? 0 : 1
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_sm_instance_crn
}

module "secrets_manager" {
  count                = var.existing_sm_instance_crn == null ? 1 : 0
  source               = "terraform-ibm-modules/secrets-manager/ibm"
  version              = "2.2.3"
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  secrets_manager_name = "${var.prefix}-secrets-manager" #tfsec:ignore:general-secrets-no-plaintext-exposure
  sm_service_plan      = "trial"
  sm_tags              = var.resource_tags
  allowed_network      = "private-only"
  endpoint_type        = "private"
}

# Best practise, use the secrets manager secret group module to create a secret group
module "secrets_manager_secret_group" {
  source                   = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version                  = "1.3.3"
  region                   = local.sm_region
  secrets_manager_guid     = local.sm_guid
  secret_group_name        = "${var.prefix}-certificates-secret-group"   #checkov:skip=CKV_SECRET_6: does not require high entropy string as is static value
  secret_group_description = "secret group used for public certificates" #tfsec:ignore:general-secrets-no-plaintext-exposure
  endpoint_type            = "private"
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
  depends_on                                = [module.secrets_manager] # Required to wait for instance to fully start
  secrets_manager_guid                      = local.sm_guid
  region                                    = local.sm_region
  ibmcloud_cis_api_key                      = var.ibmcloud_api_key # key with manager authorization to CIS
  internet_services_crn                     = var.cis_id
  dns_config_name                           = var.dns_provider_name
  ca_config_name                            = var.ca_name
  acme_letsencrypt_private_key              = var.acme_letsencrypt_private_key
  private_key_secrets_manager_instance_guid = var.private_key_secrets_manager_instance_guid
  private_key_secrets_manager_secret_id     = var.private_key_secrets_manager_secret_id
  private_key_secrets_manager_region        = var.private_key_secrets_manager_region
  service_endpoints                         = "private"
}

# TODO: Uncomment the following block once the certificate module is published
# This is necessary due to circular dependency between modules

module "secrets_manager_public_certificate" {
  source     = "terraform-ibm-modules/secrets-manager-public-cert/ibm"
  version    = "1.2.2"
  depends_on = [module.public_secret_engine]

  cert_common_name      = local.cert_common_name
  cert_description      = "Certificate for ${local.cert_common_name} domain"
  cert_name             = "${var.prefix}-public-cert"
  cert_secrets_group_id = module.secrets_manager_secret_group.secret_group_id

  secrets_manager_ca_name           = var.ca_name
  secrets_manager_dns_provider_name = var.dns_provider_name

  secrets_manager_guid   = local.sm_guid
  secrets_manager_region = local.sm_region

  service_endpoints = "private"
}
