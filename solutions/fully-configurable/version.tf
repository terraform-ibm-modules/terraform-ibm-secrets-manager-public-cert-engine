terraform {
  required_version = ">= v1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.84.1"
    }
  }
}
