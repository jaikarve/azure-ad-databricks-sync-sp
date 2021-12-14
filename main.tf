terraform {
  required_providers {
    databricks = {
      source = "databrickslabs/databricks"
      version = "~> 0.4.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2.12.0"
    }
  }
}

provider "azuread" {
  tenant_id = "3da4f926-7c6d-4ed2-9601-527c6b447f26"
}

provider "databricks" {
  host = "https://adb-984752964297111.11.azuredatabricks.net/"
  token = "dapi09a056127251d76472df5b786323a08f"
}
