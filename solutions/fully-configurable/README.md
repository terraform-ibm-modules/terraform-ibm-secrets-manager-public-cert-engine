# Secrets Manager Public Certificate Engine

This solution supports the following:
- Provisioning a Secrets Manager public certificate authority configuration to configure Let's Encrypt as a Certificate Authority (CA).
- Provisioning a Secrets Manager DNS provider configuration for IBM Cloud Internet Services.
- Provisioning a Secrets Manager to Cloud Internet Service authorization policy.

![secrets-manager-public-cert-engine-deployable-architecture](../../reference-architecture/secrets_manager_public_cert_engine.svg)

**NB:** This solution is not intended to be invoked by other modules, as it includes provider configuration. As a result, it is incompatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)
