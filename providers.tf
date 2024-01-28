# This is root/providers.tf in k8s project. This is very similar to the root/providers.tf file in the AWs2 workspace project but with
# the addition of a config_path

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs

locals {
  config = data.terraform_remote_state.kubeconfig.outputs.kubeconfig
}  
  # https://developer.hashicorp.com/terraform/language/state/remote-state-data
  # this first accesses the remote state of the AWS2 project on terraform cloud.  This is via the root/datasources.tf file in this
  # k8s workspace project.  This is data.terraform_remote_state.kubeconfig
  # Next access the terraform outputs.  
  # terraform outputs is the following:
  
    # instances = {
    #   "aws2_node-1023" = "34.220.145.62:8000"
    #   "aws2_node-9848" = "44.242.172.53:8000"
    # }
    # kubeconfig = [
    #   "export KUBECONFIG=/home/ubuntu/environment/k3s-aws2_node-9848.yaml",
    #   "export KUBECONFIG=/home/ubuntu/environment/k3s-aws2_node-1023.yaml",
    # ]
    # load_balancer_endpoint = "aws2-loadbalancer-442971132.us-west-2.elb.amazonaws.com"
  # We need to access the kubeconfig of the ouputs thus: data.terraform_remote_state.kubeconfig.outputs.kubeconfig
  # This gives us the string export KUBECONFIG=/home/ubuntu/environment/k3s-aws2_node-1023.yaml if we index on the second [1] yaml
  # Either one is fine.  See below config_path,  and use the split function.
  
  
  

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.25.2"
      # note the older version 2 years ago was 2.0.2
    }
  }
}

provider "kubernetes" {
  # Configuration options
  # The config path is the kubeconfig yaml files that are created one above the AWS2 project root folder
  # For now hardcode this
  # I have 2 nodes but given this config_path the terraform provider will only configure a single one of my 2 nodes
  # My other yaml file is k3s-aws2_node-9848.yaml used for the nginx deployment
  # Because this terarform is only deploying to one node the loadbalancer can still be used but the port 8000 will be dead on the 
  # other node and the loadbalancer target group will mark the healthchecks to that node as FAILED.  The ALB will not send traffic to this
  # node at all in this reduced state.
  
  #config_path = "../k3s-aws2_node-1023.yaml"
  
  # NOTE this config_path is for the KUBECONFIG control plane. This does not dictate where the pods will be allocated if there is more than 1 node
  # That is done by the control plane based upon resources at the nodes when the pods are created.
  # For example, with the 3 app deployment scenario, and with 2 nodes up and with the yaml file above pointing to the first node, the
  # pods were allocated as follows: nodered to the first node (1023) and granfan and influxdb to the other node (second node)node
  # https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  # The scheduler controls all of this but it can be overriden as detailed in the next link below:
  # https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/
  
  # Fetch the config_path using the data.terraform_remote_state above and the locals as defined above. See also datasources.tf file
  # Use the split function to just get the url.  local.config[1] will give us the second yaml URL.  
  # dave:~/environment/course7_terraforma_AWS2 $ terraform console
    # > split("=", "export KUBECONFIG=/home/ubuntu/environment/k3s-aws2_node-1023.yaml")[1]
    # "/home/ubuntu/environment/k3s-aws2_node-1023.yaml"
   
    config_path = split("=", local.config[1])[1]
    
}