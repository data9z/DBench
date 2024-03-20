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

variable "db_user" {}
variable "db_pwd" {}
variable "db_instance_type" {}
variable "db_disk_size" {}
variable "db_disk_type" {}
variable "db_category" {}

variable "cores" {}
variable "memory" {}

provider "alicloud" {
 access_key = var.access_key
 secret_key = var.secret_key
 region = var.region
}

resource "alicloud_vpc" "vpc" {
  vpc_name   = var.name
  cidr_block = "192.168.0.0/24"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = "192.168.0.0/26"
  zone_id    = var.zone
  depends_on = [alicloud_vpc.vpc]
}

resource "alicloud_security_group" "security_group" {
  name   = var.name
  vpc_id = alicloud_vpc.vpc.id
  depends_on = [alicloud_vswitch.vsw]
}

resource "alicloud_security_group_rule" "allow_host" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.security_group.id
  cidr_ip           = var.ext_ip
}

resource "alicloud_db_instance" "rds" {
  engine                    = "PostgreSQL"
  engine_version            = "15.0"
  instance_charge_type      = "Postpaid"
  category                  = var.db_category
  vpc_id                    = alicloud_vpc.vpc.id
  vswitch_id                = alicloud_vswitch.vsw.id
  security_group_ids        = [alicloud_security_group.security_group.id]
  instance_name             = var.name
  instance_type             = var.db_instance_type
  instance_storage          = var.db_disk_size
  db_instance_storage_type  = var.db_disk_type
  zone_id                   = var.zone
  zone_id_slave_a           = var.slave_zone
  security_ips              = ["192.168.0.0/24"]
  depends_on = [alicloud_security_group.security_group]
}

resource "alicloud_db_account" "account" {
  db_instance_id    = alicloud_db_instance.rds.id
  account_name      = var.db_user
  account_password  = var.db_pwd
  account_type      = "Super"
  depends_on = [alicloud_db_instance.rds]
}

resource "alicloud_db_account_privilege" "privilege" {
  instance_id    = alicloud_db_instance.rds.id
  account_name      = var.db_user
  privilege         = "DBOwner"
  db_names          = ["sbtest"]
  depends_on        = [alicloud_db_instance.rds, alicloud_db_database.database, alicloud_db_account.account]
}

resource "alicloud_db_database" "database" {
  instance_id = alicloud_db_instance.rds.id
  name        = "sbtest"
}

resource "alicloud_eci_container_group" "container" {
  container_group_name  = var.name
  cpu                   = var.cores
  memory                = var.memory
  restart_policy        = "Never"
  security_group_id     = alicloud_security_group.security_group.id
  vswitch_id            = alicloud_vswitch.vsw.id
  auto_create_eip       = true
  eip_bandwidth         = 1

  containers {
    image             = "registry.cn-hangzhou.aliyuncs.com/ninedata_public/sysbench:latest"
    name              = "sysbench"
    image_pull_policy = "IfNotPresent"
    commands          = ["/bin/sh", "-c", "/usr/sbin/sshd && sleep infinity"]
    ports {
      port     = 22
      protocol = "TCP"
    }
  }
  depends_on = [alicloud_security_group_rule.allow_host, alicloud_db_account_privilege.privilege]
}

output "url" {
  value = alicloud_db_instance.rds.connection_string
}

output "host" {
  value = alicloud_eci_container_group.container.internet_ip
}

output "user" {
  value = "root"
}

output "database" {
  value = "alicloud_db_database.database"
}

output "container" {
  value = true
}

output "db_port" {
  value = 5432
}

output "db_user" {
  value = var.db_user
}

output "db_pwd" {
  value = var.db_pwd
}