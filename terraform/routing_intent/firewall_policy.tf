# Firewall Policies
resource "azurerm_resource_group" "firewall_policy" {
  name     = "${var.projectname}-firewall-policy"
  location = var.core_location

  tags = local.common_tags
}

# Parent Policy
resource "azurerm_firewall_policy" "parent_firewall_policy" {
  name                = "${var.projectname}-parent-firewall-policy"
  resource_group_name = azurerm_resource_group.firewall_policy.name
  location            = azurerm_resource_group.firewall_policy.location
  sku                 = var.firewall_sku
  dynamic "intrusion_detection" {
    for_each = var.firewall_sku == "Premium" ? ["Intrusion"] : []
    content {
      mode = "Alert"
    }
  }
  

  tags = local.common_tags
  
}
# Using the parent policy to control access to the internet with app rules
resource "azurerm_firewall_policy_rule_collection_group" "parent_firewall_policy_rule" {
  for_each           = var.spoke_vnets_ip_groups
  name               = "${var.projectname}-parent-fwpolicy-rules"
  firewall_policy_id = azurerm_firewall_policy.parent_firewall_policy.id
  priority           = 500
  application_rule_collection {
    name     = "app_rule_collection1"
    priority = 500
    action   = "Allow"
    rule {
      name = "allowed_url_from_spokes"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups = [
        azurerm_ip_group.spoke_vnets["WEU-HUB"].id,
        azurerm_ip_group.spoke_vnets["NEU-HUB"].id
      ]
      destination_fqdns = [
        "*.microsoft.com",
        "*.azure.com",
        "*.ubuntu.com",
        "*.storage.azure.net",
        "*.ifconfig.me"
      ]
    }
  }
}

#using sleep to help with the timing of the firewall policy creation and destruction
resource "time_sleep" "wait_180_seconds" {

  create_duration = "300s"
}
# Child Policy - Using the child policy to control inter spoke vnet traffic
resource "azurerm_firewall_policy" "child_firewall_policy" {
  for_each            = var.spoke_vnets_ip_groups
  name                = "${each.value["name"]}-child-firewall-policy"
  resource_group_name = azurerm_resource_group.firewall_policy.name
  location            = azurerm_resource_group.firewall_policy.location
  base_policy_id      = azurerm_firewall_policy.parent_firewall_policy.id
  sku                 = var.firewall_sku
  dynamic "intrusion_detection" {
    for_each = var.firewall_sku == "Premium" ? ["Intrusion"] : []
    content {
      mode = "Alert"
    }
  }

  tags = local.common_tags
  depends_on = [
    time_sleep.wait_180_seconds
  ]
}

resource "azurerm_firewall_policy_rule_collection_group" "child_firewall_policy_rule" {
  for_each           = var.spoke_vnets_ip_groups
  name               = "${each.value["name"]}-child_firewall_policy_rule"
  firewall_policy_id = azurerm_firewall_policy.child_firewall_policy[each.key].id
  priority           = 400
  network_rule_collection {
    name     = "${each.value["location"]}-child_network_rule_collection"
    priority = 200
    action   = "Allow"
    # Spoke to Spoke Communication
    rule {
      name      = "Spoke-Spoke-Communication"
      protocols = ["Any"]
      source_ip_groups = [
        azurerm_ip_group.spoke_vnets[each.key].id
      ]
      destination_ip_groups = [
        for key, value in azurerm_ip_group.spoke_vnets : value.id if key != each.key
      ]
      destination_ports = ["*"]
    }
    rule {
      name      = "Spoke-Spoke-Communication-1"
      protocols = ["Any"]
      source_ip_groups = [

        for key, value in azurerm_ip_group.spoke_vnets : value.id if key != each.key
      ]
      destination_ip_groups = [
        azurerm_ip_group.spoke_vnets[each.key].id
      ]
      destination_ports = ["*"]
    }
  }
  nat_rule_collection {
    name     = "${each.value["location"]}-child_nat_rule_collection"
    priority = 100
    action   = "Dnat"
    rule {
      name                = "DNAT-to-${each.value["name"]}-vm"
      protocols           = ["TCP"]
      source_ip_groups    = [azurerm_ip_group.myips.id]
      destination_address = azurerm_firewall.securehub[each.key].virtual_hub[0].public_ip_addresses[0]
      destination_ports   = ["22"]
      translated_port     = "22"
      translated_address  = azurerm_network_interface.vm[each.key].private_ip_address
    }
  }
  depends_on = [
    time_sleep.wait_180_seconds,
    azurerm_ip_group.myips
  ]

}
