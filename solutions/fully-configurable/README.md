# Secrets Manager Public Certificate Engine

This solution supports the following:
- Provisioning and configuring a secrets manager public certificate DNS provider.
- Provisioning Secrets Manager Internet Service authorization.
- Configuring Let's Encrypt certificate authority.

![secrets-manager-public-cert-engine-deployable-architecture](../../reference-architecture/secrets_manager_public_cert_engine.svg)

**NB:** This solution is not intended to be invoked by other modules, as it includes provider configuration. As a result, it is incompatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)
