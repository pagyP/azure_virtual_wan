
resource "azurerm_resource_group" "main" {
    name     = "${var.projectname}-bastion-rg"
    location = "uksouth"
    tags = local.common_tags
  
}

resource "azurerm_public_ip" "main" {
    name                = "bastion-ip"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    allocation_method   = "Static"
    sku = "Standard"
    tags = local.common_tags
  
}

#Have to use Standard sku for IP based connectivity
resource "azurerm_bastion_host" "main" {
    name = "bastion-01"
    resource_group_name = azurerm_resource_group.main.name
    location = azurerm_resource_group.main.location
    copy_paste_enabled = true
    ip_connect_enabled = true
    sku = "Standard"
    ip_configuration {
        name = "bastion-ip-configuration"
        public_ip_address_id = azurerm_public_ip.main.id
        subnet_id = azurerm_subnet.main.id
    }
    tags = local.common_tags
}

resource "azurerm_virtual_network" "main" {
    name = "bastion_vnet"
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    address_space = ["10.200.200.0/24"]
    tags = local.common_tags
}

resource "azurerm_subnet" "main" {
    name = "AzureBastionSubnet"
    resource_group_name = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes = ["10.200.200.0/27"]
  
}