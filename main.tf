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

resource "ibm_is_vpc" "vpc1" {
  name = "${var.vpc_name}"
  resource_group  = "${data.ibm_resource_group.group.id}"
  tags = ["${var.environment}", "terraform"]
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
    name = "${var.vpc_name}_zone1_gateway"
    vpc = "${ibm_is_vpc.vpc1.id}"
    zone = "${var.zone1}"

    //User can configure timeouts
    timeouts {
        create = "90m"
    }
}

resource "ibm_is_public_gateway" "zone2_gateway" {
    name = "${var.vpc_name}_zone2_gateway"
    vpc = "${ibm_is_vpc.vpc1.id}"
    zone = "${var.zone2}"

    //User can configure timeouts
    timeouts {
        create = "90m"
    }
}

resource "ibm_is_public_gateway" "zone3_gateway" {
    name = "${var.vpc_name}_zone3_gateway"
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

  provisioner "local-exec" {
    command = "sleep 300"
    when    = "destroy"
  }
}

resource "ibm_is_subnet" "subnet2" {
  name            = "${var.vpc_name}-subnet2"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone2}"
  ipv4_cidr_block = "${var.cidr_block_2}"
  public_gateway  = "${ibm_is_public_gateway.zone1_gateway.id}"

  provisioner "local-exec" {
    command = "sleep 300"
    when    = "destroy"
  }
}

resource "ibm_is_subnet" "subnet3" {
  name            = "${var.vpc_name}-subnet3"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone3}"
  ipv4_cidr_block = "${var.cidr_block_3}"
  public_gateway  = "${ibm_is_public_gateway.zone1_gateway.id}"

  provisioner "local-exec" {
    command = "sleep 300"
    when    = "destroy"
  }
}

