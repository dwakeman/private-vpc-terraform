variable "vpc_name" {}
variable "resource_group" {
    default = "default"
}


data "ibm_resource_group" "group" {
    name = "${var.resource_group}"
}
variable "environment" {
    default = "sandbox"
}



resource "ibm_is_network_acl" "isNetworkACL" {
            name = "${var.vpc_name}-default-acl"
            rules=[
            {
                name = "outbound"
                action = "allow"
                protocol = "ALL"
                source = "0.0.0.0/0"
                destination = "0.0.0.0/0"
                direction = "outbound"
            },
            {
                name = "inbound"
                action = "allow"
                protocol = "ALL"
                source = "0.0.0.0/0"
                destination = "0.0.0.0/0"
                direction = "inbound"
            }
            ]
        }


resource "ibm_is_vpc" "vpc1" {
  name = "${var.vpc_name}"
  resource_group  = "${data.ibm_resource_group.group.id}"
#  default_security_group = "${ibm_is_security_group.default_security_group.id}"
  default_network_acl = "${ibm_is_network_acl.isNetworkACL.id}"
  tags = ["${var.environment}", "terraform"]
}

resource "ibm_is_security_group" "default_security_group" {
    name = "${var.vpc_name}-default-security-group"
    vpc = "${ibm_is_vpc.vpc1.id}"
}

/*
resource "null_resource" "groups" {

    provisioner "local-exec" {
        environment = {
            IBMCLOUD_COLOR=false
        }
        command = <<EOT
        ibmcloud login -c ${var.account_id} --apikey ${var.ibm_cloud_api_key} -g ${var.resource_group} -r ${var.region} \
        && ibmcloud resource groups
        EOT
    }
  
}
*/

resource "ibm_is_public_gateway" "zone1_gateway" {
    name = "${var.vpc_name}-zone1-gateway"
    vpc = "${ibm_is_vpc.vpc1.id}"
    zone = "${var.zone1}"

    //User can configure timeouts
    timeouts {
        create = "90m"
    }
}

resource "ibm_is_public_gateway" "zone2_gateway" {
    name = "${var.vpc_name}-zone2-gateway"
    vpc = "${ibm_is_vpc.vpc1.id}"
    zone = "${var.zone2}"

    //User can configure timeouts
    timeouts {
        create = "90m"
    }
}

resource "ibm_is_public_gateway" "zone3_gateway" {
    name = "${var.vpc_name}-zone3-gateway"
    vpc = "${ibm_is_vpc.vpc1.id}"
    zone = "${var.zone3}"

    //User can configure timeouts
    timeouts {
        create = "90m"
    }
}

resource "ibm_is_subnet" "subnet1" {
  name            = "${var.vpc_name}-subnet1"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone1}"
  ipv4_cidr_block = "${var.cidr_block_1}"
  public_gateway  = "${ibm_is_public_gateway.zone1_gateway.id}"
  #network_acl     = "${ibm_is_network_acl.isNetworkACL.id}"
}

resource "ibm_is_subnet" "subnet2" {
  name            = "${var.vpc_name}-subnet2"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone2}"
  ipv4_cidr_block = "${var.cidr_block_2}"
  public_gateway  = "${ibm_is_public_gateway.zone2_gateway.id}"
  #network_acl     = "${ibm_is_network_acl.isNetworkACL.id}"
}

resource "ibm_is_subnet" "subnet3" {
  name            = "${var.vpc_name}-subnet3"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone3}"
  ipv4_cidr_block = "${var.cidr_block_3}"
  public_gateway  = "${ibm_is_public_gateway.zone3_gateway.id}"
  #network_acl     = "${ibm_is_network_acl.isNetworkACL.id}"
}

