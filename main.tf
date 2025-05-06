# Data source to retrieve account ID
data "ibm_iam_account_settings" "iam_account_settings" {
}

locals {
  create_access_policy_cis = !var.skip_iam_authorization_policy && var.dns_config_name != null && var.ibmcloud_cis_api_key == null
  cis_account_id = var.cis_account_id != null ? var.cis_account_id : data.ibm_iam_account_settings.iam_account_settings.account_id
}

resource "ibm_iam_authorization_policy" "cis_service_authorization" {
  count = local.create_access_policy_cis ? 1 : 0
  roles = ["Manager", ]
  subject_attributes {
    name  = "serviceName"
    value = "secrets-manager"
  }
  subject_attributes {
    name  = "accountId"
    value = data.ibm_iam_account_settings.iam_account_settings.account_id
  }
  subject_attributes {
    name  = "serviceInstance"
    value = var.secrets_manager_guid
  }
  resource_attributes {
    name  = "serviceName"
    value = "internet-svcs"
  }
  resource_attributes {
    name  = "accountId"
    value = local.cis_account_id
  }
  resource_attributes {
    name  = "serviceInstance"
    value = split(":", var.internet_services_crn)[7] # Find service instance from the crn. Refer: https://cloud.ibm.com/docs/account?topic=account-crn#format-crn
  }
  dynamic "resource_attributes" {
    for_each = var.internet_service_domain_id[*]
    content {
      name  = "domainId"
      value = var.internet_service_domain_id
    }
  }
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.cis_service_authorization]

  create_duration = "30s"
}

# DNS config - CIS
resource "ibm_sm_public_certificate_configuration_dns_cis" "public_dns_config" {
  depends_on                     = [ibm_iam_authorization_policy.cis_service_authorization]
  count                          = var.dns_config_name != null ? 1 : 0
  instance_id                    = var.secrets_manager_guid
  region                         = var.region
  endpoint_type                  = var.service_endpoints
  name                           = var.dns_config_name
  cloud_internet_services_apikey = var.ibmcloud_cis_api_key
  cloud_internet_services_crn    = var.internet_services_crn
}

data "ibm_sm_arbitrary_secret" "ibm_secrets_manager_secret" {
  provider    = ibm.secret-store
  count       = var.private_key_secrets_manager_instance_guid != null ? 1 : 0
  region      = var.private_key_secrets_manager_region != null ? var.private_key_secrets_manager_region : var.region
  instance_id = var.private_key_secrets_manager_instance_guid
  secret_id   = var.private_key_secrets_manager_secret_id
}

locals {
  acme_letsencrypt_private_key = var.private_key_secrets_manager_instance_guid != null ? data.ibm_sm_arbitrary_secret.ibm_secrets_manager_secret[0].payload : var.acme_letsencrypt_private_key
}

# CA config - LetsEncrypt
resource "ibm_sm_public_certificate_configuration_ca_lets_encrypt" "public_ca_config" {
  depends_on               = [ibm_iam_authorization_policy.cis_service_authorization]
  count                    = var.ca_config_name != null ? 1 : 0
  instance_id              = var.secrets_manager_guid
  region                   = var.region
  endpoint_type            = var.service_endpoints
  name                     = var.ca_config_name
  lets_encrypt_environment = var.lets_encrypt_environment
  lets_encrypt_private_key = local.acme_letsencrypt_private_key
}
