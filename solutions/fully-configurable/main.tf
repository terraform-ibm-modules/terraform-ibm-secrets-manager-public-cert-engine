########################################################################################################################
# Secrets Manager Public Cert Engine
########################################################################################################################

locals {
  prefix                              = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
  parse_acme_lets_encrypt_private_key = var.acme_letsencrypt_private_key_secrets_manager_secret_crn != null ? 1 : 0
}

module "secrets_manager_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_secrets_manager_crn
}

module "secret_crn_parser" {
  count   = local.parse_acme_lets_encrypt_private_key
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.acme_letsencrypt_private_key_secrets_manager_secret_crn
}

locals {
  existing_secrets_manager_guid   = module.secrets_manager_crn_parser.service_instance
  existing_secrets_manager_region = module.secrets_manager_crn_parser.region

  secret_region = local.parse_acme_lets_encrypt_private_key == 0 ? null : module.secret_crn_parser[0].region
  secret_id     = local.parse_acme_lets_encrypt_private_key == 0 ? null : module.secret_crn_parser[0].resource
}

module "secrets_manager_public_cert_engine" {
  source = "../.."
  providers = {
    ibm              = ibm
    ibm.secret-store = ibm.secret-store
  }
  secrets_manager_guid                      = local.existing_secrets_manager_guid
  region                                    = local.existing_secrets_manager_region
  ibmcloud_cis_api_key                      = var.ibmcloud_cis_api_key
  internet_services_crn                     = var.internet_services_crn
  cis_account_id                            = var.internet_services_account_id
  internet_service_domain_id                = var.internet_service_domain_id
  dns_config_name                           = var.dns_config_name
  ca_config_name                            = "${local.prefix}${var.ca_config_name}"
  lets_encrypt_environment                  = var.lets_encrypt_environment
  acme_letsencrypt_private_key              = var.acme_letsencrypt_private_key
  service_endpoints                         = var.service_endpoints
  skip_iam_authorization_policy             = var.skip_iam_authorization_policy
  private_key_secrets_manager_instance_guid = local.existing_secrets_manager_guid
  private_key_secrets_manager_secret_id     = local.secret_id
  private_key_secrets_manager_region        = local.secret_region
}
