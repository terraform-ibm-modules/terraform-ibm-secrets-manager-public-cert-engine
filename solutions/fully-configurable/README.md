# Secrets Manager Public Certificate Engine

This solution supports the following:
- Provisioning and configuring a secrets manager public certificate DNS provider.
- Provisioning of Secrets Manager Internet Service authorization.
- Configuring of Let's Encrypt certificate authority.

![secrets-manager-public-cert-engine-deployable-architecture](../../reference-architecture/secrets_manager_public_cert_engine.svg)

**NB:** This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)
