# Secrets manager public cert engine module

[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-secrets-manager-public-cert-engine?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager-public-cert-engine/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
TODO: Replace me with description of the module(s) in this repo


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

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl

```

### Required IAM access policies

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the sample Account and IBM Cloud service names and roles with the
information in the console at
Manage > Access (IAM) > Access groups > Access policies.
-->

<!--
You need the following permissions to run this module.

- Account Management
    - **Sample Account Service** service
        - `Editor` platform access
        - `Manager` service access
    - IAM Services
        - **Sample Cloud Service** service
            - `Administrator` platform access
-->

<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!-- No permissions are needed to run this module.-->


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.7.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.54.0, < 2.0.0 |
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
| <a name="input_lets_encrypt_environment"></a> [lets\_encrypt\_environment](#input\_lets\_encrypt\_environment) | Let's Encrtyp environment (staging, production) | `string` | `"production"` | no |
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
