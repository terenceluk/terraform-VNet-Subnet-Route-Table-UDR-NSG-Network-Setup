# Create a New Resource Group
resource_group_mode = "create"
resource_group_name = "contoso-dev-app-network-rg"
location            = "Canada Central"

# Define Virtual Network Configuration
vnet_configs = {
  vnet1 = {
    name          = "contoso-dev-app-vnet"
    address_space = ["10.224.17.80/28", "10.224.17.96/27", "10.224.17.128/27"]
  }
}

# Define Route Tables
route_table_configs = {
  "rt1" = {
    name = "contoso-dev-app-frontend-snet-rt" # Name of Route Table
    routes = [
      {
        name                   = "AzureFirewallSubnet-udr"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.224.253.4"
      },
      {
        name                   = "contoso-dev-app-vnet-udr"
        address_prefix         = "10.224.17.0/24"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.224.253.4"
      },
      {
        name           = "contoso-dev-app-frontend-snet-udr"
        address_prefix = "10.224.17.80/28"
        next_hop_type  = "VnetLocal" # Options: VirtualNetworkGateway, VnetLocal, Internet
      }
    ]
  }
  "rt2" = {
    name = "contoso-dev-app-data-snet-rt" # Name of Route Table
    routes = [
      {
        name                   = "AzureFirewallSubnet-udr"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.224.253.4"
      },
      {
        name                   = "contoso-dev-app-vnet-udr"
        address_prefix         = "10.224.17.0/24"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.224.253.4"
      },
      {
        name           = "contoso-dev-app-data-snet-udr"
        address_prefix = "10.224.17.96/27"
        next_hop_type  = "VnetLocal"
      }
    ]
  }
  "rt3" = {
    name = "contoso-dev-app-asp-snet-rt" # Name of Route Table
    routes = [
      {
        name                   = "AzureFirewallSubnet-udr"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.224.253.4"
      },
      {
        name                   = "contoso-dev-app-vnet-udr"
        address_prefix         = "10.224.17.0/24"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.224.253.4"
      },
      {
        name           = "contoso-dev-app-asp-snet-udr"
        address_prefix = "10.224.17.128/27"
        next_hop_type  = "VnetLocal"
      }
    ]
  }
}

# Define NSGs and Their Rules
nsg_configs = {
  "nsg1" = {
    name           = "contoso-dev-app-frontend-snet-nsg"
    security_rules = []
  }
  "nsg2" = {
    name           = "contoso-dev-app-data-snet-nsg"
    security_rules = []
  }
  "nsg3" = {
    name           = "contoso-dev-app-asp-snet-nsg"
    security_rules = [
      # Example Rule
      /*{
        name                       = "allow-https"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        source_port_range          = "*"
        destination_port_range     = "443"
      }*/
    ]
  }
}

# Define Subnets and Their Assignments Dynamically
assignments = {
  subnet1 = {
    name             = "contoso-dev-app-frontend-snet" # The name of the subnet to be created within the VNet
    address_prefixes = ["10.224.17.80/28"] # The address for this subnet
    vnet_name        = "vnet1" # Reference the VNet defined above with its name in the vnet_configs block
    route_table      = "rt1" # Reference the Route Table defined above with its name in the route_table_configs block
    nsg              = "nsg1" # Reference the Route Table defined above with its name in the nsg_configs block
    delegation = { # Optional block for setting subnet delegation
      name = "delegation"
      service_delegation = {
        name = "Microsoft.Web/serverFarms"
      }
    }
  }
  subnet2 = {
    name             = "contoso-dev-app-data-snet"
    address_prefixes = ["10.224.17.96/27"]
    vnet_name        = "vnet1"
    route_table      = "rt2"
    nsg              = "nsg2"
  }
  subnet3 = {
    name             = "contoso-dev-app-asp-snet"
    address_prefixes = ["10.224.17.128/27"]
    vnet_name        = "vnet1"
    route_table      = "rt3"
    nsg              = "nsg3"
  }
}

/*
# Define IP Groups
ip_groups = {
  ipgroup1 = {
    name  = "contoso-dev-app-vnet-ipgroup"
    cidrs = [""10.224.17.80/28", "10.224.17.96/27", "10.224.17.128/27""]
  }
}
*/

# Tags
tags = {
  terraform_managed = "true"
  WARNING           = "DO NOT MODIFY IN PORTAL"
  environment       = "uat"
  application       = "pointofsale"
}
