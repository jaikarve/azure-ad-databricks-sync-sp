# we can use optional + defaults, then it would be easier to use, but it's an experimental feature
variable "groups" {
  description = "Map of AAD group names into object describing workspace & Databricks SQL access permissions"
  type = map(object({
    workspace_access = bool
    allow_sql_analytics_access = bool
    allow_cluster_create = bool
    allow_instance_pool_create = bool
    admin = bool  # if this group for Databricks admins
  }))
}