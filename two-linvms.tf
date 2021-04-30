#Configure Azure Stack provider
provider "azurestack" {
#    version         = "=0.9.0"
    arm_endpoint    = "${var.arm_endpoint}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    subscription_id = "${var.subscription_id}"
    tenant_id       = "${var.tenant_id }"
}
#Resource Group
resource "azurestack_resource_group" "rg" {
#    count    = "${var.rg_count}"
    name     = "${var.rg_name}"
    location = "${var.rg_location}"
  
}
# Virtual Network
resource "azurestack_virtual_network" "vn" {
  count                = "${var.vn_count}"
  name                 = "${var.vn_name}"
  location             = "${azurestack_resource_group.rg.location}" 
  resource_group_name  = "${azurestack_resource_group.rg.name}" 
  address_space        = ["${var.vn_space}"]
}
# Public IP
resource "azurestack_public_ip" "pubip" {
 
  count                         = var.pip_count
  name                          = "${var.vm_name}-${count.index}-PIP"
  location                      = "${azurestack_resource_group.rg.location}"
  resource_group_name           = "${azurestack_resource_group.rg.name}"
  public_ip_address_allocation  = "${var.pip_allocation}"
  idle_timeout_in_minutes       = 30
  tags = {
    environment = "Terraform AzureStack Demo"
  }
}
# Subnet
resource "azurestack_subnet" "sn" {
#  count                = "${var.sn_count}"
  name                 = "${var.sn_name}"
  resource_group_name  = "${azurestack_resource_group.rg.name}" 
  virtual_network_name = "${azurestack_virtual_network.vn[0].name}" 
  address_prefix       = "${var.sn_prefix}"
}
# Network Security Group
resource "azurestack_network_security_group" "nsg" {
    count               = "${var.nsg_count}"
    name                = "${var.nsg_name}"
    location            = "${azurestack_resource_group.rg.location}" 
    resource_group_name = "${azurestack_resource_group.rg.name}"
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "${var.ssh_port}"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}
# Network Interfaces
resource "azurestack_network_interface" "nic" {
  count                     = "${var.nic_count}"
  name                      = "${var.vm_name}-${count.index}-NIC"
  location                  = "${azurestack_resource_group.rg.location}"
  resource_group_name       = "${azurestack_resource_group.rg.name}"
  network_security_group_id = "${azurestack_network_security_group.nsg[0].id}"
  ip_configuration {
      name                          = "${var.nic_ip_name}"
      subnet_id                     = "${azurestack_subnet.sn.id}"
      private_ip_address_allocation = "${var.nic_allocation}"
      #public_ip_address_id          = "${azurestack_public_ip.pubip[(${count.index})].id}"
      #public_ip_address_id          = "[element(azurestack_public_ip.pubip.*.id, count.index)]"
      public_ip_address_id          = element(azurestack_public_ip.pubip.*.id, count.index)
  }
}
# Generate random password
resource "random_password" "lin-vm-password" {
  length = 16
  min_upper = 2
  min_lower = 2
  min_special = 2
  number = true
  special = true
  override_special = "!@#$%"
}
resource "azurestack_virtual_machine" "FirstTFVM" {
  count                 = "${var.vm_count}"
  name                  = "${var.vm_name}-${count.index}"
  location              = "${azurestack_resource_group.rg.location}"
  resource_group_name   = "${azurestack_resource_group.rg.name}"
  #network_interface_ids = ["${azurestack_network_interface.nic[${count.index}].id}"]
  network_interface_ids =  [element(azurestack_network_interface.nic.*.id, count.index)]
  vm_size               = "${var.vm_size}"
# Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true
# Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
     offer     = lookup(var.linux-vm-image, "offer", null)
     publisher = lookup(var.linux-vm-image, "publisher", null)
     sku       = lookup(var.linux-vm-image, "sku", null)
     version   = lookup(var.linux-vm-image, "version", null)
   }
 storage_os_disk {
   name              = "${var.vm_name}-osdisk01-${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Premium_LRS"
   }
 os_profile {
   computer_name  = "${var.vm_name}"
   admin_username = "${var.vm_user}"
   admin_password = "${random_password.lin-vm-password.result}"
   }
 os_profile_linux_config {
   disable_password_authentication = false
   }

tags = {
      environment = "K8s hardway lab"
    }
}
resource "azurestack_virtual_machine_extension" "K8sVM-RunShell" {
  count                = "${var.vm_count}"
  depends_on           = [azurestack_virtual_machine.FirstTFVM]
  #name                 = azurestack_virtual_machine.FirstTFVM.name
  name                 = element(azurestack_virtual_machine.FirstTFVM.*.name, count.index)
  location             = "${var.rg_location}"
  resource_group_name  = "${azurestack_resource_group.rg.name}"
  virtual_machine_name = element(azurestack_virtual_machine.FirstTFVM.*.name, count.index)
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  auto_upgrade_minor_version = "true"
  settings = <<SETTINGS
    {
       "script": "${base64encode(templatefile("start-play.sh", {
        AnsPlayBookURL="${var.AnsPlayBookURL}"    
        AnsPlayBookFolder="${var.AnsPlayBookFolder}"
        AnsPlayBookName="${var.AnsPlayBookName}"
        ansible_user="${var.vm_user}"
        ansible_sudo_pass="${random_password.lin-vm-password.result}"
        ssh_port="${var.ssh_port}"
        }))}"
    }
  SETTINGS

}

data "azurestack_resource_group" "rg" {
  depends_on=[azurestack_virtual_machine.FirstTFVM]
  name = "${azurestack_resource_group.rg.name}"
}
data "azurestack_public_ip" "pubip" {
  count     = "${var.pip_count}"
  depends_on=[azurestack_virtual_machine.FirstTFVM]
  name     = "${azurestack_public_ip.pubip[count.index].name}"
  #name  = [element(azurestack_public_ip.pubip.*.id, count.index)].name
  resource_group_name = "${azurestack_resource_group.rg.name}"
  
 
#  resource_group_name = var.rg_name
}
output "public_ip_address" {
  value = data.azurestack_public_ip.pubip[*].ip_address
  
  
}
output "vm_password" {
  value = random_password.lin-vm-password.result
  sensitive = true
}
output "resource_group_name" {
  value = "${data.azurestack_resource_group.rg.name}"
}