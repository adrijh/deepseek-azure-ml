locals {
  environment_name = "minimal-deepseek-inf"
  environment_version = 1
  endpoint_name = "deepseek-ep"
  deployment_name = "deepseek-dp"
}

resource "null_resource" "environment" {
  depends_on = [
    azurerm_machine_learning_workspace.this
  ]

  triggers = {
    env_name    = local.environment_name
    env_version = local.environment_version
    rg_name     = azurerm_resource_group.this.name
    ws_name     = azurerm_machine_learning_workspace.this.name
  }

  provisioner "local-exec" {
    command = <<EOT
      az ml environment create \
        --name ${self.triggers.env_name} \
        --version ${self.triggers.env_version} \
        --file environment.yml \
        --resource-group ${self.triggers.rg_name} \
        --workspace-name ${self.triggers.ws_name}
    EOT
  }
}

resource "null_resource" "model" {
  depends_on = [
    azurerm_machine_learning_workspace.this
  ]

  triggers = {
    rg_name     = azurerm_resource_group.this.name
    ws_name     = azurerm_machine_learning_workspace.this.name
  }

  provisioner "local-exec" {
    command = <<EOT
      az ml model create \
        --file model.yml \
        --resource-group ${self.triggers.rg_name} \
        --workspace-name ${self.triggers.ws_name}
    EOT
  }
}

resource "null_resource" "endpoint" {
  depends_on = [
    null_resource.model,
    null_resource.environment,
  ]

  triggers = {
    endpoint_name = local.endpoint_name
    rg_name       = azurerm_resource_group.this.name
    ws_name       = azurerm_machine_learning_workspace.this.name
  }

  provisioner "local-exec" {
    command = <<EOT
      az ml online-endpoint create \
        --name ${self.triggers.endpoint_name} \
        --file endpoint.yml \
        --resource-group ${self.triggers.rg_name} \
        --workspace-name ${self.triggers.ws_name}
    EOT
  }
}

resource "null_resource" "deployment" {
  depends_on = [
    null_resource.endpoint,
  ]

  triggers = {
    endpoint_name   = local.endpoint_name
    deployment_name = local.deployment_name
    rg_name         = azurerm_resource_group.this.name
    ws_name         = azurerm_machine_learning_workspace.this.name
  }

  provisioner "local-exec" {
    command = <<EOT
      az ml online-deployment create \
        --name ${self.triggers.deployment_name} \
        --endpoint ${self.triggers.endpoint_name} \
        --file deployment.yml \
        --all-traffic \
        --resource-group ${self.triggers.rg_name} \
        --workspace-name ${self.triggers.ws_name}
    EOT
  }
}

