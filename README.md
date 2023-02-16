# Inna infra

Infrastructure for [inna-prod] and [inna-nonprod] gcp projects.

## Links

- App: #link to the app source code

## Getting Started

### Quickstart

```bash
cd env/nonprod
terraform init
terraform plan
terraform apply
```

### Prerequisites

- [terraform](https://www.terraform.io), specifically version 1.0.7
- [berglas](https://github.com/GoogleCloudPlatform/berglas) for managing secrets
- [TFEnv](https://github.com/tfutils/tfenv) to control what version of terraform is used and requires a specific version in the Terraform config so you should not be able to use the wrong version by accident.
- Access to [`inna-nonprod`](https://console.cloud.google.com/home/dashboard?project=inna-nonprod) and [`inna-prod`](https://console.cloud.google.com/home/dashboard?project=inna-prod) GCP projects

### Google Cloud Access

```sh
brew cask install google-cloud-sdk
gcloud auth application-default login
gcloud init
# Project name is inna
```

### Install berglas

```bash
brew install berglas
```

### Working with environments

The `/env/*` folders are designed so that you can `cd` into them and run "terraform" commands. Each folder represents a separate environment and allows you to apply changes to both environments without affecting the other. Those folders also hold all env-specific configuration.

All terraform files are in the `/src/` folder. The `main.tf` uses the src folder as the "main" module and loads it, as well as providing custom variables for the specific environment.

```bash
cd env/nonprod
terraform init
terraform plan
```

### Workflow

We need to ensure terraform state is in sync with the terraform state in git. Here's how to proceed if we need to make changes.

1. Create a branch and a PR
2. Run `terraform plan`, commit and push
3. Review with another developer. After a PR review and approval, run `terraform apply`.
4. Modify or fix problems
5. Merge the PR to master and run `terraform apply` in production

This workflow ensures that nonprod env is not modified without a PR approval, and merging to master and and applying in prod are run at the same time.

No automation of those steps has been setup since gcp resources are flaky and frequently fail. Fixing problems is much faster while applying locally.

### Secrets

Secrets are managed by berglas. All secrets should be created from terraform if possible. To access the generated secrets you can use the berglas CLI

```bash
berglas access inna-nonprod-berglas/db_password
```
