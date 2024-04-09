variable "name" { default = "sysbench" }

variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "zone" {}
variable "slave_zone" {}

variable "db_cpu" {}
variable "db_mem_size" {}
variable "db_disk_size" {}
variable "db_user" {}
variable "db_pwd" {}

variable "instance_disk_type" {}
variable "instance_type" {}
variable "public_key" {}
variable "key_name" {}

variable "ext_ip" { default = "0.0.0.0/0" }

terraform {
  required_providers {
    tencentcloud = {
      source = "tencentcloudstack/tencentcloud"
    }
  }
}

provider "tencentcloud" {
 secret_id  = var.access_key
 secret_key = var.secret_key
 region     = var.region
}

resource "tencentcloud_vpc" "vpc" {
  name       = var.name
  cidr_block = "192.168.0.0/24"
}

resource "tencentcloud_subnet" "subnet" {
  name              = var.name
  vpc_id            = tencentcloud_vpc.vpc.id
  cidr_block        = "192.168.0.0/26"
  availability_zone = var.zone
  depends_on        = [tencentcloud_vpc.vpc]
}

resource "tencentcloud_security_group" "security_group" {
  name        = var.name
  depends_on  = [tencentcloud_subnet.subnet]
}

resource "tencentcloud_security_group_rule_set" "allow_host" {
  security_group_id = tencentcloud_security_group.security_group.id

  ingress {
    action      = "ACCEPT"
    cidr_block  = var.ext_ip
    protocol    = "TCP"
    port        = "22"
    description = "Allow SSH"
  }

  ingress {
    action      = "ACCEPT"
    cidr_block  = var.ext_ip
    protocol    = "TCP"
    port        = "9022"
    description = "Allow SSH"
  }

  ingress {
    action      = "ACCEPT"
    cidr_block  = "192.168.0.0/24"
    protocol    = "TCP"
    port        = "3306"
    description = "Allow MySQL"
  }

  egress {
    action      = "ACCEPT"
    cidr_block  = "0.0.0.0/0"
    protocol    = "TCP"
    description = "Allow ALL"
  }
}

resource "tencentcloud_mysql_instance" "rds" {
  instance_name     = var.name
  slave_deploy_mode = 1
  vpc_id            = tencentcloud_vpc.vpc.id
  subnet_id         = tencentcloud_subnet.subnet.id
  security_groups   = [tencentcloud_security_group.security_group.id]
  availability_zone = var.zone
  first_slave_zone  = var.slave_zone
  charge_type       = "POSTPAID"
  engine_version    = "8.0"
  mem_size          = var.db_mem_size
  cpu               = var.db_cpu
  internet_service  = 0
  volume_size       = var.db_disk_size

  depends_on = [tencentcloud_security_group.security_group]
}

resource "tencentcloud_mysql_account" "account" {
  mysql_id    = tencentcloud_mysql_instance.rds.id
  name        = var.db_user
  password    = var.db_pwd
  host        = "%"
  depends_on  = [tencentcloud_mysql_instance.rds]
}

resource "tencentcloud_mysql_database" "database" {
  instance_id         = tencentcloud_mysql_instance.rds.id
  db_name             = "sbtest"
  character_set_name  = "utf8"
}

resource "tencentcloud_mysql_privilege" "privilege" {
  mysql_id        = tencentcloud_mysql_instance.rds.id
  account_name    = var.db_user
  global          = ["SELECT", "INSERT", "UPDATE", "DELETE", "CREATE","INDEX"]
  database {
    privileges    = ["SELECT", "INSERT", "UPDATE", "DELETE", "CREATE","INDEX"]
    database_name = "sbtest"
  }
  depends_on      = [tencentcloud_mysql_account.account]
}

resource "tencentcloud_key_pair" "keypair" {
  key_name   = "${var.key_name}_mysql"
  public_key = file(var.public_key)
}

resource "tencentcloud_instance" "instance" {
  instance_name               = var.name
  image_id                    = "img-l8og963d"
  instance_type               = var.instance_type
  key_ids                     = [tencentcloud_key_pair.keypair.id]
  orderly_security_groups     = [tencentcloud_security_group.security_group.id]
  instance_charge_type        = "POSTPAID_BY_HOUR"
  availability_zone           = var.zone
  vpc_id                      = tencentcloud_vpc.vpc.id
  subnet_id                   = tencentcloud_subnet.subnet.id
  
  allocate_public_ip          = true
  internet_charge_type        = "TRAFFIC_POSTPAID_BY_HOUR"
  internet_max_bandwidth_out  = 10
  
  system_disk_type            = var.instance_disk_type
  system_disk_size            = 20
  
  depends_on = [tencentcloud_key_pair.keypair, tencentcloud_security_group_rule_set.allow_host, tencentcloud_mysql_account.account]
}

output "url" {
  value = tencentcloud_mysql_instance.rds.intranet_ip
}

output "host" {
  value = tencentcloud_instance.instance.public_ip
}

output "user" {
  value = "root"
}

output "database" {
  value = "tencentcloud_mysql_database.database"
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