data "ibm_resource_group" "vpc_group" {
    name = "${var.vpc_resource_group}"
}

data "ibm_resource_group" "kube_group" {
    name = "${var.kube_resource_group}"
}

variable "environment" {
    default = "sandbox"
}


resource "ibm_is_vpc" "vpc1" {
  name                = "${var.vpc_name}"
  resource_group      = "${data.ibm_resource_group.vpc_group.id}"
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

    depends_on = ["ibm_is_vpc.vpc1"]
}


resource "ibm_is_security_group" "default_security_group" {
    name           = "${var.vpc_name}-default-security-group"
    vpc            = "${ibm_is_vpc.vpc1.id}"
    resource_group = "${data.ibm_resource_group.vpc_group.id}"

    depends_on = ["ibm_is_vpc.vpc1"]
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

    depends_on = ["ibm_is_vpc.vpc1"]
}

resource "ibm_is_public_gateway" "zone2_gateway" {
    name = "${var.vpc_name}-zone2-gateway"
    vpc = "${ibm_is_vpc.vpc1.id}"
    zone = "${var.zone2}"

    //User can configure timeouts
    timeouts {
        create = "90m"
    }

    depends_on = ["ibm_is_vpc.vpc1"]
}

resource "ibm_is_public_gateway" "zone3_gateway" {
    name = "${var.vpc_name}-zone3-gateway"
    vpc = "${ibm_is_vpc.vpc1.id}"
    zone = "${var.zone3}"

    //User can configure timeouts
    timeouts {
        create = "90m"
    }

    depends_on = ["ibm_is_vpc.vpc1"]
}

resource "ibm_is_vpc_address_prefix" "address_prefix1" {
    name = "prefix1"
    zone = "${var.zone1}"
    vpc  = "${ibm_is_vpc.vpc1.id}"
    cidr = "${var.address_prefix_1}"

    depends_on = ["ibm_is_vpc.vpc1"]

}

resource "ibm_is_vpc_address_prefix" "address_prefix2" {
    name = "prefix2"
    zone = "${var.zone2}"
    vpc  = "${ibm_is_vpc.vpc1.id}"
    cidr = "${var.address_prefix_2}"

    depends_on = ["ibm_is_vpc.vpc1"]

}

resource "ibm_is_vpc_address_prefix" "address_prefix3" {
    name = "prefix3"
    zone = "${var.zone3}"
    vpc  = "${ibm_is_vpc.vpc1.id}"
    cidr = "${var.address_prefix_3}"

    depends_on = ["ibm_is_vpc.vpc1"]

}

resource "ibm_is_subnet" "subnet1" {
    name            = "${var.vpc_name}-subnet1"
    vpc             = "${ibm_is_vpc.vpc1.id}"
    zone            = "${var.zone1}"
    ipv4_cidr_block = "${var.cidr_block_1}"
    public_gateway  = "${ibm_is_public_gateway.zone1_gateway.id}"
    network_acl     = "${ibm_is_network_acl.isNetworkACL.id}"

    depends_on = ["ibm_is_vpc.vpc1"]
}

resource "ibm_is_subnet" "subnet2" {
    name            = "${var.vpc_name}-subnet2"
    vpc             = "${ibm_is_vpc.vpc1.id}"
    zone            = "${var.zone2}"
    ipv4_cidr_block = "${var.cidr_block_2}"
    public_gateway  = "${ibm_is_public_gateway.zone2_gateway.id}"
    network_acl     = "${ibm_is_network_acl.isNetworkACL.id}"

    depends_on = ["ibm_is_vpc.vpc1"]
}

resource "ibm_is_subnet" "subnet3" {
    name            = "${var.vpc_name}-subnet3"
    vpc             = "${ibm_is_vpc.vpc1.id}"
    zone            = "${var.zone3}"
    ipv4_cidr_block = "${var.cidr_block_3}"
    public_gateway  = "${ibm_is_public_gateway.zone3_gateway.id}"
    network_acl     = "${ibm_is_network_acl.isNetworkACL.id}"

    depends_on = ["ibm_is_vpc.vpc1"]
}





resource "ibm_container_vpc_cluster" "cluster" {
    count = "${var.provision_cluster ? 1 : 0}"

    name              = "${var.cluster_name}"
    vpc_id            = "${ibm_is_vpc.vpc1.id}"
    flavor            = "${var.flavor}"
    kube_version      = "${var.kube_version}"
    worker_count      = "${var.worker_count}"
    wait_till         = "${var.wait_till}"
    resource_group_id = "${data.ibm_resource_group.kube_group.id}"
    tags              = ["env: ${var.environment}", "vpc: ${var.vpc_name}", "terraform"]

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

    depends_on = ["ibm_is_subnet.subnet1","ibm_is_subnet.subnet2","ibm_is_subnet.subnet3"]

}
