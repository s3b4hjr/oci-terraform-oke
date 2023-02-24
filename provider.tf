provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = "ocid1.user.oc1..aaaaaaaabnxqqru3hwaihhc46zyyl6wfyjsawnbmnam7hhhseuk7f7ctk5gq"
  fingerprint      = "78:65:ae:35:85:7d:97:34:2b:12:c3:fa:61:b3:16:86"
  private_key_path     = pathexpand("~/.oci/oci_api_key.pem")
}

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "4.109.0"
    }
  }
}