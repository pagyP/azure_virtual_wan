resource "azurerm_resource_group" "ipgroups" {
  name     = "${var.projectname}-ipgroups"
  location = var.core_location

  tags = local.common_tags
}



resource "azurerm_ip_group" "spoke_vnets" {
  for_each            = var.spoke_vnets_ip_groups
  name                = each.value["name"]
  resource_group_name = azurerm_resource_group.ipgroups.name
  location            = azurerm_resource_group.ipgroups.location
  cidrs               = each.value["cidrs"]

}

resource "azurerm_ip_group" "myips" {
  name                = "myips"
  resource_group_name = azurerm_resource_group.ipgroups.name
  location            = azurerm_resource_group.ipgroups.location
  cidrs               = var.myips

}

