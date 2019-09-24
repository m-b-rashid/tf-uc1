data "azurerm_public_ip" "lb" {
  name                = "${azurerm_public_ip.belal-lb-pip.name}"
  resource_group_name = "${azurerm_resource_group.UC1.name}"
}
output "lb_ip_addr" {
  value = "${data.azurerm_public_ip.lb.ip_address}"
}
output "vmss_public_ip" {
     value = "${azurerm_public_ip.belal-lb-pip.fqdn}"
 }