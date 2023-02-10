provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = "ocid1.user.oc1..aaaaaaaahsaaprp4pm4hmy34ih5loqr7i7yr4cf66itdw7km4alsbyrd2heq"
  private_key_path = "./ci_api_key_public.pem"
  fingerprint      = "f2:38:38:dd:d6:37:2a:cf:1e:af:4b:65:f9:a1:0e:e9"
  region           = var.region
}