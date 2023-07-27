

# Virtual WAN and vHUB Resources
resource "azurerm_resource_group" "corenetworking" {
  name     = "${var.projectname}-corenetworking"
  location = var.core_location

  tags = local.common_tags
}

# Core vWAN
resource "azurerm_virtual_wan" "wan" {
  name                           = "${var.projectname}-wan"
  resource_group_name            = azurerm_resource_group.corenetworking.name
  location                       = var.core_location
  allow_branch_to_branch_traffic = true
  type                           = "Standard"

  tags = local.common_tags
}


# vHUBs
resource "azurerm_virtual_hub" "vhub" {
  for_each            = var.vhub_ip_groups
  name                = each.value["name"]
  location            = each.value["location"]
  resource_group_name = azurerm_resource_group.corenetworking.name
  address_prefix = tolist(var.vhub_ip_groups[each.key].cidrs)[0]
  virtual_wan_id         = azurerm_virtual_wan.wan.id
  sku                    = "Standard"
  hub_routing_preference = "ASPath"

  tags = local.common_tags
  
}



# Spoke VNets
resource "azurerm_virtual_network" "spoke_vnets" {
  for_each            = var.spoke_vnets_ip_groups
  name                = each.value["name"]
  location            = each.value["location"]
  resource_group_name = azurerm_resource_group.corenetworking.name
  address_space       = each.value["cidrs"]

  tags = local.common_tags
  depends_on = [
    azurerm_ip_group.spoke_vnets
  ]
}

# vHUB to Spoke VNet Connections
resource "azurerm_virtual_hub_connection" "spoke_to_vhub" {
  for_each                  = var.spoke_vnets_ip_groups
  name                      = "${each.value["name"]}-2-${azurerm_virtual_hub.vhub[each.key].name}"
  virtual_hub_id            = azurerm_virtual_hub.vhub[each.key].id
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnets[each.key].id
  internet_security_enabled = true
  

  depends_on = [
    azurerm_virtual_hub.vhub,
    azurerm_virtual_network.spoke_vnets,
    azurerm_firewall.securehub
  ]
}

resource "azurerm_virtual_hub_connection" "main" {
  name = "bastion-vnet-hub"
  virtual_hub_id = azurerm_virtual_hub.vhub["WEU-HUB"].id
  remote_virtual_network_id = azurerm_virtual_network.main.id
  internet_security_enabled = false
  
}

# Spoke Subnets
resource "azurerm_subnet" "spoke_subnets" {
  for_each             = var.spoke_subnets
  name                 = each.value["name"]
  resource_group_name  = azurerm_resource_group.corenetworking.name
  virtual_network_name = azurerm_virtual_network.spoke_vnets[each.key].name
  address_prefixes     = each.value["cidrs"]

  depends_on = [
    azurerm_virtual_network.spoke_vnets
  ]
}

# Azure Firewall 
resource "azurerm_firewall" "securehub" {
  for_each            = var.vhub_ip_groups
  name                = "${each.value["name"]}-fw"
  resource_group_name = azurerm_resource_group.corenetworking.name
  location            = each.value["location"]
  sku_name            = "AZFW_Hub"
  sku_tier            = var.firewall_sku
  virtual_hub {
    virtual_hub_id  = azurerm_virtual_hub.vhub[each.key].id
    public_ip_count = 1
  }
  firewall_policy_id = azurerm_firewall_policy.child_firewall_policy[each.key].id

  tags = local.common_tags

  
}


# Enable Routing Intent on Virtual HUB
resource "azapi_resource" "rint" {
  for_each  = var.vhub_ip_groups
  type      = "Microsoft.Network/virtualHubs/routingIntent@2022-11-01"
  name      = "${each.value["name"]}-RInt"
  parent_id = azurerm_virtual_hub.vhub[each.key].id
  body = jsonencode({
    properties = {
      routingPolicies = [
        {
          name         = "PrivateTrafficPolicy"
          destinations = ["PrivateTraffic"]
          nextHop      = "${azurerm_firewall.securehub[each.key].id}"
        },
        {
          name         = "InternetTraffic"
          destinations = ["Internet"]
          nextHop      = "${azurerm_firewall.securehub[each.key].id}"
        }
      ]
    }
  })
  depends_on = [
    azurerm_virtual_hub.vhub,
    azurerm_firewall.securehub
  ]
}