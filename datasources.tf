# This is the root/datasources.tf file in the k8s project workspace

# terraform_remote_state datasource used to access remote state of the AWS2 project from this k8s project
# We can access the state on the terraform cloud.  (both AWS2 workspace project and k8s workspace project have their terraform
# state kept on terraform cloud under separate workspaces)
# https://developer.hashicorp.com/terraform/language/state/remote-state-data

data "terraform_remote_state" "kubeconfig" {
  backend = "remote"
  # remote is used to access terraform state on terraform cloud.  There are 2 workspaces on there, this one aws2-k8s and
  # the AWS2 project workspace course7-terraform-adv-AWS-dev
  
  config = {
    organization = "course7_terraform_adv_AWS_org"
    workspaces = {
      name = "course7-terraform-adv-AWS-dev"
    }
  }
}