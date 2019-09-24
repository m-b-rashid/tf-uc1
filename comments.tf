
# resource "azurerm_virtual_machine" "site" {
#   count = 1
#   name                = "${var.hostname}-site-${count.index}"
#   location            = "${var.location}"
#   resource_group_name = "${azurerm_resource_group.UC1.name}"
#   vm_size             = "${var.vm_size}"

#   network_interface_ids         = ["${azurerm_network_interface.belal-nic.id}"]
#   delete_os_disk_on_termination = "true"

#   storage_image_reference {
#     publisher = "${var.image_publisher}"
#     offer     = "${var.image_offer}"
#     sku       = "${var.image_sku}"
#     version   = "${var.image_version}"
#   }

#   storage_os_disk {
#     name              = "${var.hostname}-osdisk"
#     managed_disk_type = "Standard_LRS"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#   }

#   os_profile {
#     computer_name  = "${var.hostname}"
#     admin_username = "${var.admin_username}"
#     admin_password = "${var.admin_password}"
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   # It's easy to transfer files or templates using Terraform.
#   provisioner "file" {
#     source      = "scripts/setup.sh"
#     destination = "/home/${var.admin_username}/setup.sh"

#     connection {
#       type     = "ssh"
#       user     = "${var.admin_username}"
#       password = "${var.admin_password}"
#       host     = "${azurerm_public_ip.belal-pip.fqdn}"
#     }
#   }

#   # This shell script starts our Apache server and prepares the demo environment.
#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /home/${var.admin_username}/setup.sh",
#       "sudo /home/${var.admin_username}/setup.sh",
#     ]

#     connection {
#       type     = "ssh"
#       user     = "${var.admin_username}"
#       password = "${var.admin_password}"
#       host     = "${azurerm_public_ip.belal-pip.fqdn}"
#     }
#   }
# }