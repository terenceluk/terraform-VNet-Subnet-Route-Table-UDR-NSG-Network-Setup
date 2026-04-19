# Terraform Azure Networking Modules

This repository provisions Azure core networking components with Terraform using a composable module structure. The root module orchestrates creation of:

- Resource groups
- Virtual networks
- Subnets
- Route tables
- Route table to subnet associations
- Network security groups
- NSG to subnet associations

An IP Group module is also included in the repository, but it is currently commented out in the root module and is not active by default.

The original blog post referenced by the repository is here:

<https://blog.terenceluk.com/2025/07/modules-for-deploying-azure-core-networking-components-with-terraform.html>

## What This Repo Does

The root module uses maps of objects to let you define a complete network topology in one place. You describe:

- One or more VNets in `vnet_configs`
- One or more route tables in `route_table_configs`
- One or more NSGs in `nsg_configs`
- One or more subnets and their relationships in `assignments`

The root module then wires those definitions together and creates the required Azure associations automatically.

## Repository Structure

```text
.
|-- dev.tfvars
|-- main.tf
|-- outputs.tf
|-- provider.tf
|-- terraform.tf
|-- variables.tf
`-- networking-modules
		|-- ip-group
		|-- nsg
		|-- nsg-assignment
		|-- route-table
		|-- route-table-assignment
		|-- subnet
		`-- vnet
```

## Root Module Flow

The deployment order is:

1. Create or reference the resource group.
2. Create VNets.
3. Create subnets inside the referenced VNets.
4. Create route tables.
5. Associate route tables to subnets where `route_table` is set.
6. Create NSGs.
7. Associate NSGs to subnets where `nsg` is set.

Subnet associations are derived from the `assignments` map, which acts as the topology map for each subnet.

## Prerequisites

- Terraform 1.x
- Azure subscription access with permission to create networking resources
- An authenticated Azure session if you remove the hardcoded subscription placeholder in `provider.tf`

## Provider and Terraform Configuration

The repository currently uses:

- Local backend in `terraform.tf`
- `hashicorp/azurerm` provider version `4.2.0`
- A placeholder `subscription_id` value in `provider.tf`

Before running this configuration, update `provider.tf` with a valid authentication approach for your environment. For example, replace the placeholder subscription ID and use the authentication mechanism your pipeline or workstation expects.

## Quick Start

1. Edit `provider.tf` and set the correct Azure subscription and authentication method.
2. Copy `dev.tfvars` or create your own `.tfvars` file.
3. Update the VNet, subnet, NSG, and route table definitions.
4. Run Terraform:

```bash
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

If you want to reference an existing resource group instead of creating one, set:

```hcl
resource_group_mode = "import"
```

## Example Topology Model

The main pattern in this repository is the `assignments` map. Each entry defines a subnet and optionally references:

- A VNet key from `vnet_configs`
- A route table key from `route_table_configs`
- An NSG key from `nsg_configs`
- A subnet delegation block

Example:

```hcl
assignments = {
	frontend = {
		name             = "contoso-dev-app-frontend-snet"
		address_prefixes = ["10.224.17.80/28"]
		vnet_name        = "vnet1"
		route_table      = "rt1"
		nsg              = "nsg1"
		delegation = {
			name = "delegation"
			service_delegation = {
				name = "Microsoft.Web/serverFarms"
			}
		}
	}
}
```

## Root Module Inputs

### `location`

Azure region for supported resources.

Type:

```hcl
string
```

### `resource_group_name`

Name of the resource group to create or reference.

Type:

```hcl
string
```

### `resource_group_mode`

Controls whether the resource group is created or looked up.

Allowed values:

- `create`
- `import`

Type:

```hcl
string
```

Default:

```hcl
"create"
```

### `vnet_configs`

Map of virtual network definitions.

Type:

```hcl
map(object({
	name          = string
	address_space = list(string)
}))
```

### `route_table_configs`

Map of route table definitions and route entries.

Type:

```hcl
map(object({
	name = string
	routes = list(object({
		name                   = string
		address_prefix         = string
		next_hop_type          = string
		next_hop_in_ip_address = optional(string)
	}))
}))
```

Note:

- When `next_hop_type` is `VirtualAppliance`, `next_hop_in_ip_address` must be set.

### `nsg_configs`

Map of NSG definitions and NSG rules.

Type:

```hcl
map(object({
	name = string
	security_rules = list(object({
		name                         = string
		priority                     = number
		direction                    = string
		access                       = string
		protocol                     = string
		source_address_prefix        = string
		destination_address_prefix   = optional(string)
		destination_address_prefixes = optional(list(string))
		source_port_range            = string
		destination_port_range       = string
	}))
}))
```

Notes:

- Use `destination_address_prefix` for a single prefix.
- Use `destination_address_prefixes` for multiple prefixes.
- Empty `security_rules = []` is valid.

### `assignments`

Map of subnet definitions and optional associations.

Type:

```hcl
map(object({
	name             = string
	address_prefixes = list(string)
	vnet_name        = string
	route_table      = optional(string)
	nsg              = optional(string)
	delegation = optional(object({
		name = string
		service_delegation = object({
			name = string
		})
	}))
}))
```

Notes:

- `vnet_name` must match a key in `vnet_configs`, not the Azure resource name itself.
- `route_table` must match a key in `route_table_configs` when provided.
- `nsg` must match a key in `nsg_configs` when provided.
- If `route_table` or `nsg` is omitted or set to `null`, that association is skipped.

### `tags`

Tags applied to supported resources.

Type:

```hcl
map(string)
```

Default:

```hcl
{}
```

## Root Module Outputs

The root module publishes the following outputs for downstream consumption:

### `resource_group_id`

The ID of the resource group used by this deployment.

### `resource_group_name`

The name of the resource group used by this deployment.

### `vnet_ids`

Map of VNet IDs keyed by the `vnet_configs` map key.

### `vnet_names`

Map of VNet names keyed by the `vnet_configs` map key.

### `vnet_address_spaces`

Map of VNet address spaces keyed by the `vnet_configs` map key.

### `subnet_ids`

Map of subnet IDs keyed by the `assignments` map key.

### `route_table_ids`

Map of route table IDs keyed by the `route_table_configs` map key.

### `nsg_ids`

Map of NSG IDs keyed by the `nsg_configs` map key.

## Included Child Modules

### `networking-modules/vnet`

Creates a single Azure virtual network.

Inputs:

- `name`
- `address_space`
- `location`
- `resource_group_name`
- `tags`

Outputs:

- `id`
- `name`
- `address_space`

### `networking-modules/subnet`

Creates a single Azure subnet with optional delegation.

Inputs:

- `name`
- `address_prefixes`
- `resource_group_name`
- `virtual_network_name`
- `delegation`

Outputs:

- `id`

### `networking-modules/route-table`

Creates a single Azure route table and all routes defined for it.

Inputs:

- `name`
- `location`
- `resource_group_name`
- `routes`
- `tags`

Outputs:

- `id`

### `networking-modules/route-table-assignment`

Associates route tables to subnets.

Inputs:

- `route_table_assignments`

Outputs:

- None

### `networking-modules/nsg`

Creates a single Azure network security group and all defined rules.

Inputs:

- `name`
- `location`
- `resource_group_name`
- `security_rules`
- `tags`

Outputs:

- `id`

### `networking-modules/nsg-assignment`

Associates NSGs to subnets.

Inputs:

- `nsg_assignments`

Outputs:

- None

### `networking-modules/ip-group`

Creates Azure IP Groups.

Status:

- Present in the repository
- Not currently enabled from the root module

Inputs:

- `ip_groups`
- `location`
- `resource_group_name`
- `tags`

Outputs:

- `ip_group_ids`

## Example `dev.tfvars`

This repository already includes a sample `dev.tfvars` file that demonstrates:

- Creating a resource group
- Deploying one VNet
- Deploying three subnets
- Deploying three route tables
- Deploying three NSGs
- Associating one route table and one NSG per subnet

Use it as a starting point, but review the CIDR ranges, naming standards, tags, and next hop IP addresses before applying in a real environment.

## Known Constraints

- The backend is local, so state is stored on the machine running Terraform unless you change the backend.
- The provider configuration contains a placeholder subscription ID and must be updated before use.
- The IP Group module is not wired into the root module.

## Suggested Improvements

If you want to extend this repository, the highest value next steps are:

1. Move provider authentication details out of source and into environment-driven authentication.
2. Add remote state support.
3. Re-enable the IP Group module if your design requires reusable CIDR grouping.
4. Add `terraform validate` and `terraform fmt -check` to CI.

## License and Ownership

No license file is currently included in the repository. Add one if you plan to distribute or reuse this code outside a private context.
