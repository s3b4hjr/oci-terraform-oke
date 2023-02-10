data "oci_identity_availability_domains" "ads" {
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaasjp6tq4pf4iiprgqlnpkasui3razi7apvjaijp76i2vtmksbe72q"
}

data "oci_core_services" "AllOCIServices" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

## compartment resource

resource "oci_identity_compartment" "tf-compartment" {
  # Required
  compartment_id = var.tenancy_ocid
  description    = "Compartment for Terraform resources."
  name           = var.compartment_name
}


# vcn
# Source from https://registry.terraform.io/modules/oracle-terraform-modules/vcn/oci/
module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.1.0"
  # insert the 5 required variables here

  # Required Inputs
  compartment_id = oci_identity_compartment.tf-compartment.id
  region         = var.region

  internet_gateway_route_rules = null
  local_peering_gateways       = null
  nat_gateway_route_rules      = null

  # Optional Inputs
  vcn_name      = "vcn-dev"
  vcn_dns_label = "vcnmodule"
  vcn_cidrs     = ["10.0.0.0/16"]

  create_internet_gateway = false
  create_nat_gateway      = false
  create_service_gateway  = false
}

# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list

resource "oci_core_security_list" "private-security-list" {

  # Required
  compartment_id = oci_identity_compartment.tf-compartment.id
  vcn_id         = module.vcn.vcn_id

  # Optional
  display_name = "security-list-for-private-subnet"

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1  
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1  
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
    }
  }
}

# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list

resource "oci_core_security_list" "public-security-list" {

  # Required
  compartment_id = oci_identity_compartment.tf-compartment.id
  vcn_id         = module.vcn.vcn_id

  # Optional
  display_name = "security-list-for-public-subnet"
  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1  
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1  
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
    }
  }

}

resource "oci_core_security_list" "my_api_endpoint_subnet_sec_list" {
  compartment_id = oci_identity_compartment.tf-compartment.id
  display_name   = "my_api_endpoint_subnet_sec_list"
  vcn_id         = module.vcn.vcn_id

  # egress_security_rules

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.nodepool_subnet_cidr
  }

  egress_security_rules {
    protocol         = 1
    destination_type = "CIDR_BLOCK"
    destination      = var.nodepool_subnet_cidr

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")

    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.nodepool_subnet_cidr

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.nodepool_subnet_cidr

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = 1
    source   = var.nodepool_subnet_cidr

    icmp_options {
      type = 3
      code = 4
    }
  }

}

resource "oci_core_security_list" "my_nodepool_subnet_sec_list" {
  compartment_id = oci_identity_compartment.tf-compartment.id
  display_name   = "my_nodepool_subnet_sec_list"
  vcn_id         = module.vcn.vcn_id

  egress_security_rules {
    protocol         = "All"
    destination_type = "CIDR_BLOCK"
    destination      = var.nodepool_subnet_cidr
  }

  egress_security_rules {
    protocol    = 1
    destination = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.api_endpoint_subnet_cidr

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.api_endpoint_subnet_cidr

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "All"
    source   = var.nodepool_subnet_cidr
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.api_endpoint_subnet_cidr
  }

  ingress_security_rules {
    protocol = 1
    source   = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }

}

# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet

resource "oci_core_subnet" "vcn-private-subnet" {

  # Required
  compartment_id = oci_identity_compartment.tf-compartment.id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = var.private_subnet_cidr

  # Optional
  # Caution: For the route table id, use module.vcn.nat_route_id.
  # Do not use module.vcn.nat_gateway_id, because it is the OCID for the gateway and not the route table.
  route_table_id    = module.vcn.nat_route_id
  security_list_ids = [oci_core_security_list.private-security-list.id]
  display_name      = "private-subnet"
}

# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet

resource "oci_core_subnet" "vcn-public-subnet" {

  # Required
  compartment_id = oci_identity_compartment.tf-compartment.id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = var.public_subnet_cidr

  # Optional
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public-security-list.id]
  display_name      = "public-subnet"
}

resource "oci_core_subnet" "my_lb_subnet" {
  cidr_block     = var.lb_subnet_cidr
  compartment_id = oci_identity_compartment.tf-compartment.id
  vcn_id         = module.vcn.vcn_id
  display_name   = "my_lb_subnet"

  security_list_ids = [oci_core_security_list.public-security-list.id]
  route_table_id    = oci_core_route_table.my_rt_via_igw.id
}

resource "oci_core_subnet" "my_api_endpoint_subnet" {
  cidr_block        = var.api_endpoint_subnet_cidr
  compartment_id    = oci_identity_compartment.tf-compartment.id
  vcn_id            = module.vcn.vcn_id
  display_name      = "my_api_endpoint_subnet"
  security_list_ids = [oci_core_security_list.private-security-list.id, oci_core_security_list.my_api_endpoint_subnet_sec_list.id]
  route_table_id    = oci_core_route_table.my_rt_via_igw.id
}

resource "oci_core_subnet" "my_nodepool_subnet" {
  cidr_block     = var.nodepool_subnet_cidr
  compartment_id = oci_identity_compartment.tf-compartment.id
  vcn_id         = module.vcn.vcn_id
  display_name   = "my_nodepool_subnet"

  security_list_ids          = [oci_core_security_list.private-security-list.id, oci_core_security_list.my_nodepool_subnet_sec_list.id]
  route_table_id             = oci_core_route_table.my_rt_via_natgw_and_sg.id
  prohibit_public_ip_on_vnic = true
}

## routeing tables

resource "oci_core_route_table" "my_rt_via_igw" {
  compartment_id = oci_identity_compartment.tf-compartment.id
  vcn_id         = module.vcn.vcn_id
  display_name   = "my_rt_via_igw"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.my_igw.id
  }
}

resource "oci_core_route_table" "my_rt_via_natgw_and_sg" {
  compartment_id = oci_identity_compartment.tf-compartment.id
  vcn_id         = module.vcn.vcn_id
  display_name   = "my_rt_via_natgw"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.my_natgw.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.my_sg.id
  }
}

# internet gateway

resource "oci_core_internet_gateway" "my_igw" {
  compartment_id = oci_identity_compartment.tf-compartment.id
  display_name   = "my_igw"
  vcn_id         = module.vcn.vcn_id
}

# nat gateway
resource "oci_core_nat_gateway" "my_natgw" {
  compartment_id = oci_identity_compartment.tf-compartment.id
  display_name   = "my_natgw"
  vcn_id         = module.vcn.vcn_id
}

resource "oci_core_service_gateway" "my_sg" {
  compartment_id = oci_identity_compartment.tf-compartment.id
  display_name   = "my_sg"
  vcn_id         = module.vcn.vcn_id
  services {
    service_id = lookup(data.oci_core_services.AllOCIServices.services[0], "id")
  }
}


## oke cluster public api private nodes

module "oci-oke" {
  source                                                  = "github.com/oracle-devrel/terraform-oci-arch-oke"
  oci_vcn_ip_native                                       = true
  tenancy_ocid                                            = var.tenancy_ocid
  compartment_ocid                                        = oci_identity_compartment.tf-compartment.id
  oke_cluster_name                                        = var.oke_cluster_name
  k8s_version                                             = var.k8s_version
  pool_name                                               = var.pool_name
  node_shape                                              = var.node_shape
  node_ocpus                                              = var.node_ocpus
  node_memory                                             = var.node_memory
  node_count                                              = var.node_count
  use_existing_vcn                                        = true
  vcn_id                                                  = module.vcn.vcn_id
  is_api_endpoint_subnet_public                           = true                                      # OKE API Endpoint will be public (Internet facing)
  api_endpoint_subnet_id                                  = oci_core_subnet.my_api_endpoint_subnet.id # public subnet
  is_lb_subnet_public                                     = true                                      # OKE LoadBalanacer will be public (Internet facing)
  lb_subnet_id                                            = oci_core_subnet.my_lb_subnet.id           # public subnet
  is_nodepool_subnet_public                               = false
  nodepool_subnet_id                                      = oci_core_subnet.my_nodepool_subnet.id
  max_pods_per_node                                       = 50
  cluster_options_add_ons_is_kubernetes_dashboard_enabled = false
  cluster_options_add_ons_is_tiller_enabled               = false
}

# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster

# resource "oci_containerengine_cluster" "oke-cluster" {
#     # Required
#     compartment_id = oci_identity_compartment.tf-compartment.id
#     kubernetes_version = "v1.24.1"
#     name = "dev"
#     vcn_id = module.vcn.vcn_id

#     # Optional
#     options {
#         add_ons{
#             is_kubernetes_dashboard_enabled = false
#             is_tiller_enabled = false
#         }
#         kubernetes_network_config {
#             pods_cidr = "10.244.0.0/16"
#             services_cidr = "10.96.0.0/16"
#         }
#         service_lb_subnet_ids = [oci_core_subnet.vcn-public-subnet.id]
#     }  
# }

# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_node_pool

# resource "oci_containerengine_node_pool" "oke-node-pool" {
#     # Required
#     cluster_id = oci_containerengine_cluster.oke-cluster.id
#     compartment_id = oci_identity_compartment.tf-compartment.id
#     kubernetes_version = "v1.24.1"
#     name = "pool1"
#     node_config_details{
#         placement_configs{
#             availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
#             subnet_id = oci_core_subnet.vcn-private-subnet.id
#         } 
#         # placement_configs{
#         #     availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
#         #     subnet_id = oci_core_subnet.vcn-private-subnet.id
#         # }
#         #  placement_configs{
#         #     availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
#         #     subnet_id = oci_core_subnet.vcn-private-subnet.id
#         # }
#         size = 2
#     }
#     node_shape = "VM.Standard2.1"

#     # Using image Oracle-Linux-7.x-<date>
#     # Find image OCID for your region from https://docs.oracle.com/iaas/images/ 
#     node_source_details {
#          image_id = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa3ibxbkfvmcdyshvkuzhpc2wx2ofmpjyyjf5tyh3eqge7vc7d5rtq"
#          source_type = "image"
#     }

#     # Optional
#     initial_node_labels {
#         key = "name"
#         value = "dev"
#     }    
# }

