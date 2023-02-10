variable "tenancy_ocid" {
  type = string
}

variable "compartment_name" {
  type = string
}

variable "region" {
  type = string
}
variable "oke_cluster_name" {
  default = "oke-cluster"
}

variable "k8s_version" {
  default = "v1.24.1"
}

variable "pool_name" {
  default = "pool1"
}

variable "node_shape" {
  default = "VM.Standard2.1"
}

variable "node_ocpus" {
  default = 1
}

variable "node_memory" {
  default = 4
}

variable "node_count" {
  default = 2
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "nodepool_subnet_cidr" {
  default = "10.0.3.0/24"
}

variable "lb_subnet_cidr" {
  default = "10.0.4.0/24"
}

variable "api_endpoint_subnet_cidr" {
  default = "10.0.5.0/24"
}
