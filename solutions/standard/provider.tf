provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

provider "ibm" {
  alias            = "secret-store"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}
