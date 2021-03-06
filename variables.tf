variable "vpc_name" {
    
}

variable "vpc_resource_group" {
    default = "default"
}

variable "region" {
    default = "us-south"
}

variable "generation" {
    default = 1
}

variable "zone1" {
  default = "us-south-1"
}

variable "zone2" {
  default = "us-south-2"
}

variable "zone3" {
  default = "us-south-3"
}

variable address_prefix_1 {
    default = "10.1.0.0/16"
}

variable address_prefix_2 {
    default = "10.2.0.0/16"
}

variable address_prefix_3 {
    default = "10.3.0.0/16"
}

variable cidr_block_1 {
    default = "10.1.1.0/24"
}

variable cidr_block_2 {
    default = "10.2.1.0/24"
}

variable cidr_block_3 {
    default = "10.3.1.0/24"
}

variable provision_cluster {
    description = "If set to true, provision the cluster"
    default = 0
}
variable cluster_name {

}

variable "kube_resource_group" {
    default = "default"
}

variable flavor {
    default = "b2.4x16"
}

variable "kube_version" {
    # to determine available versions run "ic ks versions"
    default = "1.17.4"
}
variable "worker_count" {
    default = 1
}

variable "wait_till" {
    default = "IngressReady"
}

variable account_id {

}

variable ibm_cloud_api_key {

}
