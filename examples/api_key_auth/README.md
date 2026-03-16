# Secrets Manager public certificate engine using API key authentication

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=secrets-manager-public-cert-engine-api_key_auth-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager-public-cert-engine/tree/main/examples/api_key_auth">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

A simple example to set up a Secret Manager public certificate engine which uses an API key for authentication to CIS.

The following resources are provisioned by this example:

- A new resource group, if an existing one is not passed in.
- A Secrets Manager instance.
- A CIS configuration for a (DNS) domain as part of the public certificate engine with an API key.
- A CIS configuration for a certificate authority (CA) as part of the public certificate engine.
- A active public certificate to demonstrate functionality of public certificate engine.

### Before you begin

The CIS instance should own a domain and the public certificate must be for that domain.
