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
  default = "v1.25.4"
}

variable "pool_name" {
  default = "pool1"
}

variable "node_shape" {
  default = "VM.Standard3.Flex"
# default = "VM.Standard.A1.Flex"
}

variable "node_image" {
  default = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa2ki57s6vokigjzzi7rbhjgxjxa5irt67frqkibr6obgrrqjy5iza"
  # default = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaarbvtai3sxdzkhya7wd5laqsoa53gng2cjr4ya437o3mvfcyi6lbq" a1flex
}

variable "node_ocpus" {
  default = 1
}

variable "node_memory" {
  default = 6
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

variable "freeform_tags" {
  description = "simple key-value pairs to tag the resources created using freeform tags."
  type        = map(string)
  default     = null
}

variable "defined_tags" {
  description = "predefined and scoped to a namespace to tag the resources created using defined tags."
  type        = map(string)
  default     = null
}

# compute instance parameters

variable "instance_ad_number" {
  description = "The availability domain number of the instance. If none is provided, it will start with AD-1 and continue in round-robin."
  type        = number
  default     = 1
}

variable "instance_count" {
  description = "Number of identical instances to launch from a single module."
  type        = number
  default     = 1
}

variable "instance_display_name" {
  description = "(Updatable) A user-friendly name for the instance. Does not have to be unique, and it's changeable."
  type        = string
  default     = "module_instance_flex"
}

variable "instance_flex_memory_in_gbs" {
  type        = number
  description = "(Updatable) The total amount of memory available to the instance, in gigabytes."
  default     = 8
}


variable "instance_flex_cpu" {
  type = number
  default = 2
}
variable "instance_flex_ocpus" {
  type        = number
  description = "(Updatable) The total number of OCPUs available to the instance."
  default     = 1
}

variable "instance_state" {
  type        = string
  description = "(Updatable) The target state for the instance. Could be set to RUNNING or STOPPED."
  default     = "RUNNING"

  validation {
    condition     = contains(["RUNNING", "STOPPED"], var.instance_state)
    error_message = "Accepted values are RUNNING or STOPPED."
  }
}

variable "shape" {
  description = "The shape of an instance."
  type        = string
  default     = "VM.Standard.E3.Flex"
}

variable "baseline_ocpu_utilization" {
  description = "(Updatable) The baseline OCPU utilization for a subcore burstable VM instance"
  type        = string
  default     = "BASELINE_1_1"
}


variable "source_type" {
  description = "The source type for the instance."
  type        = string
  default     = "image"
}


variable "ssh_public_keys" {
  description = "Public SSH keys to be included in the ~/.ssh/authorized_keys file for the default user on the instance. To provide multiple keys, see docs/instance_ssh_keys.adoc."
  type        = string
  default     = null
}

variable "public_ip" {
  description = "Whether to create a Public IP to attach to primary vnic and which lifetime. Valid values are NONE, RESERVED or EPHEMERAL."
  type        = string
  default     = "EPHEMERAL"
}

variable "boot_volume_backup_policy" {
  description = "Choose between default backup policies : gold, silver, bronze. Use disabled to affect no backup policy on the Boot Volume."
  type        = string
  default     = "disabled"
}

variable "block_storage_sizes_in_gbs" {
  description = "Sizes of volumes to create and attach to each instance."
  type        = list(string)
  default     = [50]
}



## Mysql

variable "admin_password" {
    type        = string
}

variable "admin_username" {
    type        = string
}

variable "mysql_shape" {
  default = "MySQL.VM.Standard.E4.1.8GB"
}

variable "mysql_data_storage_in_gb" {
  default = "50"
}

variable "dev_sql_display_name" {
  default = "dev-sql"
}