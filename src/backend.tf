terraform {
  required_providers {
    berglas = {
      source  = "sethvargo/berglas"
      version = "0.1.0"
    }
  }
  experiments = [module_variable_optional_attrs]
}
