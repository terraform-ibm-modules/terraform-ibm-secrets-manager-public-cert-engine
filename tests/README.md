# Secrets Manager Public Certificate Engine

This solution supports the following:
- Provisioning and configuring CIS DNS.
- Provisioning of SM CIS authorization.
- Configuring a Let's Encrypt certificate authority.

![secrets-manager-ublic-cert-engine-deployable-architecture](../../reference-architecture/secrets_manager_public_cert_engine.svg)

**NB:** This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

No requirements.

### Modules

No modules.

### Resources

No resources.

### Inputs

No inputs.

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
