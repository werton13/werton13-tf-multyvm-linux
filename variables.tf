#Azure Stack Provider Variables
variable "arm_endpoint" {}
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
# Resource Group
#variable "rg_count" {
#    description = "1 deploy rg /0 n rg"
#    default = "0"
#}
variable "rg_name" {
    description = "Resource Group  Name"
}
variable "rg_location" {
    description = "location of resource group"
}

# Virtual Network
variable "vn_count" {
  description = "1 deploy rg / 0 n rg"
  default = "0"
}
variable "vm_count" {
  description = "1 deploy rg / 0 n rg"
  default = "0"
}
variable "vn_name" {
  description = "The name of the Virtual Network"
}
variable "vn_space" {
  description = "The range ip ex 172.16.0.0/16"
}
# Subnet
variable "sn_count" {
  description = "1 deploy rg / 0 n rg"
  default = "0"
}
variable "sn_name" {
  description = "The name of the Subnet"
}
variable "sn_prefix" {
  description = "The range ip ex 172.16.2.0/24"
}
# Network Security Group
variable "nsg_count" {
  description = "1 deploy rg / 0 n rg"
  default = "0"
}
variable "nsg_name" {
  description = "The name of the Subnet"
}
variable "ssh_port" {
  description = "ssh port "
}
# Network Interface
variable "nic_count" {
  description = "1 deploy rg / 0 no ni"
  default = "0"
}
#variable "nic_name" {
#  description = "The name of the Network Interface"
#}
variable "nic_ip_name" {
  description = "The name of the IP configuration"
  default = "TerraformLAB-IPConfig"
}
variable "nic_allocation" {
  description = "Dynamic or Static ?"
  default = "dynamic"
}
# Public IP
variable "pip_count" {
#  description = "1 deploy rg / 0 no ni"
  default = "1"
}
variable "pip_name" {
  description = "The name of the Public IP address"
  default = "PIP"
}

variable "pip_allocation" {
  description = "Dynamic or Static ?"
}

variable "vm_name" {
  description = "The name of the Virtual Machine"
}
variable "vm_size" {
  description = "The size of the VM ex F8s"
}
#variable "vm_osdisk_name" {
#  description = "The name of the OS disk"
#}
variable "vm_user" {
  description = "The admin user of the VM"
}


variable  "linux-vm-image"  {

        type  =  map(string)
        description  =  "virtual  machine  image  information"
        default  =  {
                publisher  =  "canonical"
                offer      =  "UbuntuServer"
                sku        =  "18.04-LTS"
                version    =  "latest"
        }
}

variable "AnsPlayBookURL" {

  description = "URL for GitHub repo with Ansible Playbook"

}
variable "AnsPlayBookFolder" {
  description = "folder name to extract Git repo"
}
variable "AnsPlayBookName" {
  description = "Ansible playbook name "
}


