terraform {
  required_version = ">=0.13"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.78.0"
    }
  }
   experiments = [module_variable_optional_attrs]
}
