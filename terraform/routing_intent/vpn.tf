# resource "azurerm_vpn_gateway" "vpn" {
#     name = "vpngw-uks"
#     location = "uksouth"
#     resource_group_name = azurerm_resource_group.corenetworking.name
#     virtual_hub_id = azurerm_virtual_hub.vhub["uks-HUB"].id
#     scale_unit = 1
# }

# resource "azurerm_vpn_gateway_connection" "vpn" {
#     name = "vpngw-uks-2-onprem"
#     //resource_group_name = azurerm_resource_group.corenetworking.name
#     vpn_gateway_id = azurerm_vpn_gateway.vpn.id
#     remote_vpn_site_id = azurerm_vpn_site.vpn.id

#     vpn_link {
#       vpn_site_link_id = azurerm_vpn_site.vpn.link[0].id
#       shared_key = "CHANGE_ME"
#       bgp_enabled = true
#       name = "link-to-on-prem"
#     }

# }

# resource "azurerm_vpn_site" "vpn" {
#   device_vendor       = "Pfsense"
#   location            = "uksouth"
#   name                = "On-Prem-UKS"
#   resource_group_name = azurerm_resource_group.corenetworking.name
#   virtual_wan_id      = azurerm_virtual_wan.wan.id
#   link {
#     fqdn          = "CHANGE_ME"
#     name          = "link-to-on-prem-uks"
#     provider_name = "isp"
#     speed_in_mbps = 100
#     bgp {
#       asn             = 65050
#       peering_address = "192.168.1.1"
#     }
#   }
# }