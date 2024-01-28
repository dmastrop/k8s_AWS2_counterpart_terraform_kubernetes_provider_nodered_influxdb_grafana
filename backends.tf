# This is root/backends.tf in the k8s project. This is very similar in structure to the root/backends.tf for the AWS2 workspace/project
# This will push the state of this k8s workspace on Cloud9 to the aws2-k8s workspace on terraform cloud.
# The AWS2 state is seprate from the k8s state on terraform cloud so that we can teardown and change the k8s via terraform without
# affecting the AWS terraform infra!

terraform {
  cloud {
    organization = "course7_terraform_adv_AWS_org"

    workspaces {
      name = "aws2-k8s"
    }
  }
}
