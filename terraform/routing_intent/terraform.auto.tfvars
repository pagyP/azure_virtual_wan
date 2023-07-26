core_location = "westeurope"
projectname   = "vwan"
firewall_sku  = "Standard"
vhub_ip_groups = {
  "WEU-HUB" = {
    name     = "WEU-HUB"
    cidrs    = ["172.16.2.0/23"]
    location = "westeurope"
    # avoid adding more CIDR for HUB as it can only have 1 CIDR
  }
  "NEU-HUB" = {
    name     = "NEU-HUB"
    cidrs    = ["172.16.0.0/23"]
    location = "northeurope"
    # avoid adding more CIDR for HUB as it can only have 1 CIDR
  }
}

spoke_vnets_ip_groups = {
  "WEU-HUB" = {
    name     = "WEU-SPOKE-1"
    cidrs    = ["192.168.180.0/24"]
    location = "westeurope"
  }
  "NEU-HUB" = {
    name     = "NEU-SPOKE-1"
    cidrs    = ["192.168.200.0/24"]
    location = "northeurope"
  }
}

spoke_subnets = {
  "WEU-HUB" = {
    name  = "WEU-SPOKE-1-Subnet-1"
    cidrs = ["192.168.180.0/27"]
  }
  "NEU-HUB" = {
    name  = "NEU-SPOKE-1-Subnet-1"
    cidrs = ["192.168.200.0/27"]
  }
}