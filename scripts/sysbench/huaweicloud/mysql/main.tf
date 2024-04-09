variable "name" {
  default = "sysbench"
}

variable "ext_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "access_key" {}
variable "secret_key" {}

variable "region" {}
variable "zone" {}
variable "slave_zone" {}

variable "db_instance_type" {}
variable "db_user" {}
variable "db_pwd" {}
variable "db_disk_size" {}
variable "db_disk_type" {}

variable "vm_flavor" {}
variable "public_key" {}
variable "eip_type" {}


terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.36.0"
    }
  }
}

provider "huaweicloud" {
 access_key = var.access_key
 secret_key = var.secret_key
 region = var.region
}

resource "huaweicloud_vpc" "vpc" {
  name       = var.name
  cidr       = "192.168.0.0/24"
}

resource "huaweicloud_vpc_subnet" "subnet" {
  name              = var.name
  vpc_id            = huaweicloud_vpc.vpc.id
  cidr              = "192.168.0.0/26"
  gateway_ip        = "192.168.0.2"
  availability_zone = var.zone
  depends_on        = [huaweicloud_vpc.vpc]
}

resource "huaweicloud_networking_secgroup" "security_group" {
  name   = var.name
  depends_on = [huaweicloud_vpc_subnet.subnet]
}

resource "huaweicloud_networking_secgroup_rule" "allow_host" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  action            = "allow"
  ports             = "22,9022"
  priority          = 1
  security_group_id = huaweicloud_networking_secgroup.security_group.id
  remote_ip_prefix  = var.ext_ip
}

resource "huaweicloud_rds_instance" "rds" {
  name                = var.name
  flavor              = var.db_instance_type
  ha_replication_mode = "async"
  vpc_id              = huaweicloud_vpc.vpc.id
  subnet_id           = huaweicloud_vpc_subnet.subnet.id
  security_group_id   = huaweicloud_networking_secgroup.security_group.id
  availability_zone   = [var.zone, var.slave_zone]
  charging_mode       = "postPaid"

  db {
    type     = "MySQL"
    version  = "8.0"
  }

  volume {
    type = var.db_disk_type
    size = var.db_disk_size
  }

  depends_on = [huaweicloud_networking_secgroup.security_group]
}

resource "huaweicloud_rds_mysql_account" "account" {
  instance_id = huaweicloud_rds_instance.rds.id
  name        = var.db_user
  password    = var.db_pwd
  hosts       = ["%"]
  depends_on = [huaweicloud_rds_instance.rds]
}

resource "huaweicloud_rds_mysql_database" "database" {
  instance_id   = huaweicloud_rds_instance.rds.id
  name          = "sbtest"
  character_set = "utf8"
}

resource "huaweicloud_rds_mysql_database_privilege" "privilege" {
  instance_id = huaweicloud_rds_instance.rds.id
  db_name     = "sbtest"

  users {
    name     = var.db_user
    readonly = false
  }

  depends_on = [huaweicloud_rds_mysql_account.account, huaweicloud_rds_mysql_database.database]
}

resource "huaweicloud_kps_keypair" "keypair" {
  name       = var.name
  public_key = file(var.public_key)
}

resource "huaweicloud_compute_instance" "instance" {
  name                = var.name
  image_name          = "CentOS 7.9 64bit"
  flavor_id           = var.vm_flavor
  key_pair            = huaweicloud_kps_keypair.keypair.id
  security_group_ids  = [huaweicloud_networking_secgroup.security_group.id]
  charging_mode       = "postPaid"
  availability_zone   = var.zone

  network {
    uuid = huaweicloud_vpc_subnet.subnet.id
  }
  bandwidth {
    size        = 10
    share_type  = "PER"
    charge_mode = "traffic"
  }
  system_disk_type    = "SAS"
  system_disk_size    = 40
  eip_type            = var.eip_type
  depends_on = [huaweicloud_kps_keypair.keypair, huaweicloud_networking_secgroup_rule.allow_host, huaweicloud_rds_mysql_account.account]
}

output "url" {
  value = huaweicloud_rds_instance.rds.private_ips[0]
}

output "host" {
  value = huaweicloud_compute_instance.instance.public_ip
}

output "user" {
  value = "root"
}

output "database" {
  value = "huaweicloud_rds_mysql_database.database"
}

output "container" {
  value = false
}

output "db_port" {
  value = 3306
}

output "db_user" {
  value = var.db_user
}

output "db_pwd" {
  value = var.db_pwd
}