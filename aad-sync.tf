// read group members of given groups from AzureAD every time Terraform is started
data "azuread_group" "this" {
  for_each = local.all_groups
  display_name = each.value
}

locals {
  all_groups = toset(keys(var.groups))
  admin_groups = toset([for k,v in var.groups: k if v.admin])
}

// create or remove groups within databricks - all governed by "groups" variable
resource "databricks_group" "this" {
  for_each = data.azuread_group.this
  display_name = each.key
  workspace_access = var.groups[each.key].workspace_access
  allow_cluster_create = var.groups[each.key].allow_cluster_create
  allow_instance_pool_create = var.groups[each.key].allow_instance_pool_create
}

data "azuread_service_principal" "this" {
  for_each = toset(flatten([for g in data.azuread_group.this: g.members]))
  object_id = each.value
}

// read users from AzureAD every time Terraform is started
/*
data "azuread_user" "this" {
  for_each = toset(flatten([for g in data.azuread_group.this: g.members]))
  object_id = each.value
}
*/

// all governed by AzureAD, create or remove users from databricks workspace
/*resource "databricks_user" "this" {
  for_each = data.azuread_user.this
  user_name = each.value.user_principal_name
  display_name = each.value.display_name
  active = each.value.account_enabled
}*/

resource "databricks_service_principal" "this" {
  for_each = data.azuread_service_principal.this
  application_id = each.value.application_id
  display_name = each.value.display_name
}

// put users to respective groups
resource "databricks_group_member" "this" {
  for_each = toset(flatten(
    [for group_name in local.all_groups:
      [for member_id in data.azuread_group.this[group_name].members:
        jsonencode({
          user: member_id,
          group: group_name
        })]]))
  group_id = databricks_group.this[jsondecode(each.value).group].id
  member_id = databricks_service_principal.this[jsondecode(each.value).user].id
}

// Provisioning of admins
/*
data "azuread_group" "admins" {
  for_each = local.admin_groups
  display_name = each.value
}

data "azuread_user" "admins" {
  for_each = toset(flatten([for g in data.azuread_group.this: g.members]))
  object_id = each.value
}

data "databricks_group" "admins" {
    display_name = "admins"
}

resource "databricks_group_member" "admins" {
  for_each = toset(flatten(
    [for group_name in local.admin_groups:
      [for member_id in data.azuread_group.admins[group_name].members: member_id]]))
  group_id = data.databricks_group.admins.id
  member_id = databricks_user.this[each.value].id
}
*/