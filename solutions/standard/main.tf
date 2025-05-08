########################################################################################################################
# Secrets Manager Public Cert Engine
########################################################################################################################

module "crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_secrets_manager_crn
}

locals {
  existing_secrets_manager_guid   = module.crn_parser.service_instance
  existing_secrets_manager_region = module.crn_parser.region
}

module "secrets_manager_public_cert_engine" {
  source = "../.."
  providers = {
    ibm              = ibm
    ibm.secret-store = ibm.secret-store
  }
  secrets_manager_guid                      = local.existing_secrets_manager_guid
  region                                    = var.region
  ibmcloud_cis_api_key                      = var.ibmcloud_cis_api_key
  internet_services_crn                     = var.internet_services_crn
  cis_account_id                            = var.cis_account_id
  internet_service_domain_id                = var.internet_service_domain_id
  dns_config_name                           = var.dns_config_name
  ca_config_name                            = var.ca_config_name
  lets_encrypt_environment                  = var.lets_encrypt_environment
  acme_letsencrypt_private_key              = var.acme_letsencrypt_private_key
  service_endpoints                         = "private"
  skip_iam_authorization_policy             = var.skip_iam_authorization_policy
  private_key_secrets_manager_instance_guid = var.private_key_secrets_manager_instance_guid
  private_key_secrets_manager_secret_id     = var.private_key_secrets_manager_secret_id
  private_key_secrets_manager_region        = var.private_key_secrets_manager_region
}
