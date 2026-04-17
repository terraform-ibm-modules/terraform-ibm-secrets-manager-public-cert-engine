terraform {
  required_version = ">= v1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "2.0.2"
    }
  }
}
