##############################################################################
# Input Variables
##############################################################################

variable "secrets_manager_guid" {
  type        = string
  description = "GUID of secrets manager instance to create the secret engine in"
}

variable "region" {
  type        = string
  description = "Region where resources will be created or fetched from"
  default     = "us-south"
}

variable "ibmcloud_cis_api_key" {
  type        = string
  description = "Optional, when not using IAM authorization, use an API key for CIS DNS configuration"
  default     = null
  sensitive   = true
}

variable "internet_services_crn" {
  type        = string
  description = "CRN of the CIS instance to authorize Secrets Manager against"
  default     = null

  validation {
    condition     = var.dns_config_name != null ? var.internet_services_crn != null : true
    error_message = "A value for 'internet_services_crn' must be passed to create a DNS config for public_cert secrets engine"
  }
}

variable "cis_account_id" {
  type        = string
  description = "Account ID of the CIS instance (only needed if different from Secrets Manager account)"
  default     = null
}

variable "internet_service_domain_id" {
  type        = string
  description = "(optional) Specific domain in the CIS to authorize Secrets Manager access to."
  default     = null
}

variable "dns_config_name" {
  type        = string
  description = "Name of the DNS config for the public_cert secrets engine"
  default     = null
}

variable "ca_config_name" {
  type        = string
  description = "Name of the CA config for the public_cert secrets engine"
  default     = null
}

variable "lets_encrypt_environment" {
  type        = string
  description = "Let's Encrypt environment (staging, production)"
  default     = "production"
}

variable "acme_letsencrypt_private_key" {
  type        = string
  description = "The private key generated by the ACME account creation tool. Required if private_key_secrets_manager_instance_guid and private_key_secrets_manager_secret_id are not set."
  default     = null
  sensitive   = true

  validation {
    condition     = var.ca_config_name != null ? var.acme_letsencrypt_private_key == null ? (var.private_key_secrets_manager_instance_guid != null && var.private_key_secrets_manager_secret_id != null) : true : true
    error_message = "A value for 'acme_letsencrypt_private_key' must be provided, or both `private_key_secrets_manager_instance_guid` and `private_key_secrets_manager_secret_id` must be provided to pull the private key to create a CA config for public_cert secrets engine."
  }
}

variable "service_endpoints" {
  type        = string
  description = "The service endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private`"
  default     = "public"
  validation {
    condition     = contains(["public", "private"], var.service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection!"
  }
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits Secrets Manager to create a DNS config in the CIS specified in `internet_services_crn`. WARNING: An authorization policy must exist before a DNS config can be created, OR an API key must be provided in `ibmcloud_cis_api_key`"
  default     = false
}

variable "private_key_secrets_manager_instance_guid" {
  type        = string
  description = "The Secrets Manager instance GUID of the Secrets Manager containing your ACME private key. Required if acme_letsencrypt_private_key is not set."
  default     = null
}

variable "private_key_secrets_manager_secret_id" {
  type        = string
  description = "The secret ID of your ACME private key. Required if acme_letsencrypt_private_key is not set. If both are set, this value will be used as the private key."
  default     = null
}

variable "private_key_secrets_manager_region" {
  type        = string
  description = "The region of the Secrets Manager instance containing your ACME private key. (Only needed if different from the region variable)"
  default     = null
}

##############################################################################
