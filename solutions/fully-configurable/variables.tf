variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key used to provision resources."
  sensitive   = true
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

variable "existing_secrets_manager_crn" {
  type        = string
  description = "CRN of an existing secrets manager instance to create the secret engine in."
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-us-south. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}


variable "ibmcloud_cis_api_key" {
  type        = string
  description = "If not using IAM authorization, supply an API key for Internet Services DNS configuration. [Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-secrets-manager-cli#secrets-manager-configurations-cli)."
  default     = null
  sensitive   = true
}

variable "internet_services_crn" {
  type        = string
  description = "The CRN of the Internet Service instance to authorize Secrets Manager against. For creating a public certificate, if using Cloud Internet Service for DNS then `internet_service_crn` is a required input. [Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-secrets-manager-cli#secrets-manager-configurations-cli)."
  default     = null
}

variable "internet_services_account_id" {
  type        = string
  description = "The Account ID of the Internet Service instance (only needed if different from Secrets Manager account)."
  default     = null
}

variable "internet_service_domain_id" {
  type        = string
  description = "Specific domain in the Internet Service to authorize Secrets Manager access to."
  default     = null
}

variable "dns_config_name" {
  type        = string
  description = "Name of the DNS config for the public_cert secrets engine. If passing a value for `dns_config_name` a value for `internet_services_crn` is required. [Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-secrets-manager-cli#secrets-manager-configurations-cli)."
  default     = null

  validation {
    condition     = var.dns_config_name != null ? var.internet_services_crn != null : true
    error_message = "A value for 'internet_services_crn' must be passed to create a DNS config for public certificate secrets engine."
  }
}

variable "ca_config_name" {
  type        = string
  description = "Name of the CA config for the public certificate secrets engine. If a prefix input variable is specified, it is added to the value in the `<prefix>-value` format. [Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-secrets-manager-cli#secrets-manager-configurations-cli)."
  default     = "cert-auth"
}

variable "lets_encrypt_environment" {
  type        = string
  description = "Let's Encrypt environment (staging, production). [Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-secrets-manager-cli#secrets-manager-configurations-cli)."
  default     = "production"

  validation {
    condition     = contains(["staging", "production"], var.lets_encrypt_environment)
    error_message = "lets_encrypt_environment must be either 'staging' or 'production'."
  }
}

variable "acme_letsencrypt_private_key" {
  type        = string
  description = "The private key generated by the ACME account creation tool. Alternatively `acme_letsencrypt_private_key_secrets_manager_secret_crn` can be provided. Required if acme_letsencrypt_private_key_secrets_manager_secret_crn is not set. [Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-secrets-manager-cli#secrets-manager-configurations-cli)."
  sensitive   = true
  default     = null
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits Secrets Manager to create a DNS config in the CIS specified in `internet_services_crn`. WARNING: An authorization policy must exist before a DNS config can be created, OR an API key must be provided in `ibmcloud_cis_api_key`."
  default     = false
}

variable "acme_letsencrypt_private_key_secrets_manager_secret_crn" {
  type        = string
  description = "The secret CRN of your ACME private key. Required if acme_letsencrypt_private_key is not set. If both are set, this value will be used as the private key."
  default     = null

  validation {
    condition = (
      var.acme_letsencrypt_private_key_secrets_manager_secret_crn != null ||
      var.acme_letsencrypt_private_key != null
    )
    error_message = "If `acme_letsencrypt_private_key` is not set, you must provide a value for `acme_letsencrypt_private_key_secrets_manager_secret_crn`."
  }
}
