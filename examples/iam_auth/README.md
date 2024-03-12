# Secrets Manager public certificate engine using an IBM IAM authorization policy

A simple example to set up a Secret Manager public certificate engine which uses IBM IAM authorization policy for authentication to CIS.

The following resources are provisioned by this example:

- A new resource group, if an existing one is not passed in.
- A Secrets Manager instance.
- An IBM IAM authorization policy for Secrets Manager to create CIS DNS configs.
- A CIS configuration for a (DNS) domain as part of the public certificate engine.
- A CIS configuration for a certificate authority (CA) as part of the public certificate engine.
- A active public certificate to demonstrate functionality of public certificate engine.

### Before you begin

The CIS instance should own a domain and the public certificate must be for that domain.
