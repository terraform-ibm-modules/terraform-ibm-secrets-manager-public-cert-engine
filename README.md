# Secrets manager public cert engine module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-secrets-manager-public-cert-engine?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager-public-cert-engine/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
This module configures a public certificates engine for a Secrets Manager instance. For more information about enabling Secrets Manager for public certificates, see [Preparing to order public certificates](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-prepare-order-certificates).

The module handles the following resources:

- [Authorization between Secrets Manager and Cloud Internet Services (CIS)](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-prepare-order-certificates&interface=ui#authorize-cis)
- [CIS DNS](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-prepare-order-certificates&interface=ui#connect-dns-provider) configuration
- [Let's Encrypt certificate authority](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-prepare-order-certificates&interface=ui#connect-certificate-authority) configuration

The two configurations make up the `public_cert` secrets type. This module also signs the intermediate certificate authority (CA) when the engine is created.
## Before you begin

Make sure that you have the following prerequisites:

- An IBM Cloud Internet Services (CIS) instance
- A private key `.pem` file generated by the [ACME account creation tool](https://github.com/ibm-cloud-security/acme-account-creation-tool)

:information_source: **Tip:** The [Secrets Manager module](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager) provides automation to create a Secret Manager instance.

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-secrets-manager-public-cert-engine](#terraform-ibm-secrets-manager-public-cert-engine)
* [Examples](./examples)
    * [Secrets Manager public certificate engine using API key authentication](./examples/api_key_auth)
    * [Secrets Manager public certificate engine using an IBM IAM authorization policy](./examples/iam_auth)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and links to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in Authoring Guidelines in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- This heading should always match the name of the root level module (aka the repo name) -->
## terraform-ibm-secrets-manager-public-cert-engine

### Usage

```hcl
# Provider aliases
providers = {
    ibm              = ibm
    ibm.secret-store = ibm
}

# Authentication with IAM policy
module "public_secret_engine" {
  source                       = "terraform-ibm-modules/secrets-manager-public-cert-engine/ibm"
  version                      = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  secrets_manager_guid         = "<secrets_manager_instance_id>"
  region                       = "us-south"
  dns_config_name              = "My DNS Config"
  internet_services_crn        = "<internet_services_instance_id>"
  ca_config_name               = "My CA Config"
  acme_letsencrypt_private_key = "<acme_letsnecrypt_private_key>" # pragma: allowlist secret
}

# Authentication with API key
module "public_secret_engine" {
  source                       = "terraform-ibm-modules/secrets-manager-public-cert-engine/ibm"
  version                      = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  secrets_manager_guid         = "<secrets_manager_instance_id>"
  region                       = "us-south"
  dns_config_name              = "My DNS Config"
  internet_services_crn        = "<internet_services_instance_id>"
  ca_config_name               = "My CA Config"
  acme_letsencrypt_private_key = "<acme_letsnecrypt_private_key>" # pragma: allowlist secret
  ibmcloud_cis_api_key         = "<ibmcloud_api_key>"             # pragma: allowlist secret
}

# Authentication with IAM policy, ACME private key stored in Secrets Manager
module "public_secret_engine" {
  source                       = "terraform-ibm-modules/secrets-manager-public-cert-engine/ibm"
  version                      = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  secrets_manager_guid         = "<secrets_manager_instance_id>"
  region                       = "us-south"
  dns_config_name              = "My DNS Config"
  internet_services_crn        = "<internet_services_instance_id>"
  ca_config_name               = "My CA Config"
  secrets_manager_instance_id  = "<my secrets manager instance ID>"   # pragma: allowlist secret
  secrets_manager_secret_id    = "<the secret ID of the private key>" # pragma: allowlist secret
}

# Authentication with API key, ACME private key stored in Secrets Manager
module "public_secret_engine" {
  source                       = "terraform-ibm-modules/secrets-manager-public-cert-engine/ibm"
  version                      = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  secrets_manager_guid         = "<secrets_manager_instance_id>"
  region                       = "us-south"
  dns_config_name              = "My DNS Config"
  internet_services_crn        = "<internet_services_instance_id>"
  ca_config_name               = "My CA Config"
  ibmcloud_cis_api_key         = "<ibmcloud_api_key>"                 # pragma: allowlist secret
  secrets_manager_instance_id  = "<my secrets manager instance ID>"   # pragma: allowlist secret
  secrets_manager_secret_id    = "<the secret ID of the private key>" # pragma: allowlist secret
}
```

Because the ACME Let's Encrypt private key is a multi-line string, you may encounter errors passing it into terraform. You can store it as an arbitrary secret in Secrets Manager which terraform will pull or you can use one of the following methods to provide it through the CLI:

### In the .tfvars file:
```
acme_letsencrypt_private_key = <<-EOT # pragma: allowlist secret
-----PRIVATE KEY-----           # pragma: allowlist secret
CONTENTS
OFYOUR
PRIVATEKEY
-----END PRIVATE KEY-----
EOT
```

### From the command line:
```
export TF_VAR_acme_letsencrypt_private_key='-----PRIVATE KEY----- # pragma: allowlist secret
CONTENTS
OFYOUR
PRIVATEKEY
-----END PRIVATE KEY-----'
```
This will work with most UNIX-based shells. You may need to change the `'` character depending on your shell.

### As a variable in Terraform:
```
acme_letsencrypt_private_key = "-----PRIVATE KEY-----\nCONTENTS\nOFYOUR\nPRIVATEKEY\n-----END PRIVATE KEY-----" # pragma: allowlist secret
```
You can replace the new lines in the private key with newline characters `\n`.

### Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **IAM Access Groups** service
        - `Editor` platform access
    - **IAM Identity** service
        - `Operator` platform access
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **Secrets Manager** service
        - `Administrator` platform access
        - `Manager` service access


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.79.0, < 2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.cis_service_authorization](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_sm_public_certificate_configuration_ca_lets_encrypt.public_ca_config](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_public_certificate_configuration_ca_lets_encrypt) | resource |
| [ibm_sm_public_certificate_configuration_dns_cis.public_dns_config](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_public_certificate_configuration_dns_cis) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |
| [ibm_sm_arbitrary_secret.ibm_secrets_manager_secret](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/sm_arbitrary_secret) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acme_letsencrypt_private_key"></a> [acme\_letsencrypt\_private\_key](#input\_acme\_letsencrypt\_private\_key) | The private key generated by the ACME account creation tool. Required if private\_key\_secrets\_manager\_instance\_guid and private\_key\_secrets\_manager\_secret\_id are not set. | `string` | `null` | no |
| <a name="input_ca_config_name"></a> [ca\_config\_name](#input\_ca\_config\_name) | Name of the CA config for the public\_cert secrets engine | `string` | `null` | no |
| <a name="input_cis_account_id"></a> [cis\_account\_id](#input\_cis\_account\_id) | Account ID of the CIS instance (only needed if different from Secrets Manager account) | `string` | `null` | no |
| <a name="input_dns_config_name"></a> [dns\_config\_name](#input\_dns\_config\_name) | Name of the DNS config for the public\_cert secrets engine | `string` | `null` | no |
| <a name="input_ibmcloud_cis_api_key"></a> [ibmcloud\_cis\_api\_key](#input\_ibmcloud\_cis\_api\_key) | Optional, when not using IAM authorization, use an API key for CIS DNS configuration | `string` | `null` | no |
| <a name="input_internet_service_domain_id"></a> [internet\_service\_domain\_id](#input\_internet\_service\_domain\_id) | (optional) Specific domain in the CIS to authorize Secrets Manager access to. | `string` | `null` | no |
| <a name="input_internet_services_crn"></a> [internet\_services\_crn](#input\_internet\_services\_crn) | CRN of the CIS instance to authorize Secrets Manager against | `string` | `null` | no |
| <a name="input_lets_encrypt_environment"></a> [lets\_encrypt\_environment](#input\_lets\_encrypt\_environment) | Let's Encrypt environment (staging, production) | `string` | `"production"` | no |
| <a name="input_private_key_secrets_manager_instance_guid"></a> [private\_key\_secrets\_manager\_instance\_guid](#input\_private\_key\_secrets\_manager\_instance\_guid) | The Secrets Manager instance GUID of the Secrets Manager containing your ACME private key. Required if acme\_letsencrypt\_private\_key is not set. | `string` | `null` | no |
| <a name="input_private_key_secrets_manager_region"></a> [private\_key\_secrets\_manager\_region](#input\_private\_key\_secrets\_manager\_region) | The region of the Secrets Manager instance containing your ACME private key. (Only needed if different from the region variable) | `string` | `null` | no |
| <a name="input_private_key_secrets_manager_secret_id"></a> [private\_key\_secrets\_manager\_secret\_id](#input\_private\_key\_secrets\_manager\_secret\_id) | The secret ID of your ACME private key. Required if acme\_letsencrypt\_private\_key is not set. If both are set, this value will be used as the private key. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where resources will be created or fetched from | `string` | `"us-south"` | no |
| <a name="input_secrets_manager_guid"></a> [secrets\_manager\_guid](#input\_secrets\_manager\_guid) | GUID of secrets manager instance to create the secret engine in | `string` | n/a | yes |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The service endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private` | `string` | `"public"` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits Secrets Manager to create a DNS config in the CIS specified in `internet_services_crn`. WARNING: An authorization policy must exist before a DNS config can be created, OR an API key must be provided in `ibmcloud_cis_api_key` | `bool` | `false` | no |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
