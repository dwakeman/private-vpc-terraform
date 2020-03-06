data "ibm_resource_group" "group" {
    name = "${var.resource_group}"
}
variable "environment" {
    default = "sandbox"
}


resource "ibm_is_vpc" "vpc1" {
  name                = "${var.vpc_name}"
  resource_group      = "${data.ibm_resource_group.group.id}"
  tags                = ["${var.environment}", "terraform"]
}

resource "ibm_is_network_acl" "isNetworkACL" {
    name = "${var.vpc_name}-default-acl"
    vpc = "${ibm_is_vpc.vpc1.id}"
    rules=[
    {
        name = "outbound"
        action = "allow"
#                protocol = "ALL"
        source = "0.0.0.0/0"
        destination = "0.0.0.0/0"
        direction = "outbound"
    },
    {
        name = "inbound"
        action = "allow"
#                protocol = "ALL"
        source = "0.0.0.0/0"
        destination = "0.0.0.0/0"
        direction = "inbound"
    }
    ]
}


resource "ibm_is_security_group" "default_security_group" {
    name           = "${var.vpc_name}-default-security-group"
    vpc            = "${ibm_is_vpc.vpc1.id}"
    resource_group = "${data.ibm_resource_group.group.id}"
}

resource "ibm_is_security_group_rule" "default_security_group_rule_all_inbound" {
    group = "${ibm_is_security_group.default_security_group.id}"
    direction = "inbound"

    depends_on = ["ibm_is_security_group.default_security_group"]
 }

resource "ibm_is_security_group_rule" "default_security_group_rule_iks_management" {
    group = "${ibm_is_security_group.default_security_group.id}"
    direction = "inbound"
    tcp = {
        port_min = 30000
        port_max = 32767
    }

    depends_on = ["ibm_is_security_group.default_security_group"]
 }

resource "ibm_is_security_group_rule" "default_security_group_rule_all_outbound" {
    group = "${ibm_is_security_group.default_security_group.id}"
    direction = "outbound"

    depends_on = ["ibm_is_security_group.default_security_group"]
 }

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
  network_acl     = "${ibm_is_network_acl.isNetworkACL.id}"
}

resource "ibm_is_subnet" "subnet2" {
  name            = "${var.vpc_name}-subnet2"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone2}"
  ipv4_cidr_block = "${var.cidr_block_2}"
  public_gateway  = "${ibm_is_public_gateway.zone2_gateway.id}"
  network_acl     = "${ibm_is_network_acl.isNetworkACL.id}"
}

resource "ibm_is_subnet" "subnet3" {
  name            = "${var.vpc_name}-subnet3"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone3}"
  ipv4_cidr_block = "${var.cidr_block_3}"
  public_gateway  = "${ibm_is_public_gateway.zone3_gateway.id}"
  network_acl     = "${ibm_is_network_acl.isNetworkACL.id}"
}

#resource "ibm_is_ssh_key" "isSSHKey" {
#    name = "samaritan-key"
#    public_key = "${var.ssh_key}"
#}

resource "ibm_container_vpc_cluster" "cluster" {
  name              = "${var.cluster_name}"
  vpc_id            = "${ibm_is_vpc.vpc1.id}"
  flavor            = "${var.flavor}"
  worker_count      = "${var.worker_count}"
  resource_group_id = "${data.ibm_resource_group.group.id}"
  tags              = ["${var.environment}", "terraform"]

  zones = [
    {
        subnet_id = "${ibm_is_subnet.subnet1.id}"
        name      = "${var.zone1}"
    },
    {
        subnet_id = "${ibm_is_subnet.subnet2.id}"
        name      = "${var.zone2}"
    },
    {
        subnet_id = "${ibm_is_subnet.subnet3.id}"
        name      = "${var.zone3}"
    }

  ]

}
