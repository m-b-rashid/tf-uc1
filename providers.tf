provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  # use azure cli to authenticate 
  version = "~> 1.31"
}
resource "azurerm_resource_group" "UC1" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}