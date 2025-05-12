terraform {
  required_version = ">= 1.9.0"
  required_providers {
    # Use "greater than or equal to" range in modules
    ibm = {
      source                = "IBM-Cloud/ibm"
      version               = ">= 1.76.0, < 2.0.0"
      configuration_aliases = [ibm, ibm.secret-store]
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1, < 1.0.0"
    }
  }
}
