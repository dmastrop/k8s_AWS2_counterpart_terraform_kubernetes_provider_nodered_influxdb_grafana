This is the counterpart project to the AWS2 project
This workspace project has its own dedicated terraform cloud state separate from the AWS2 infra project workspace, so that 
terraform modifications are decoupled between AWS infra and k8s configuration.
This k8s project deploys influxdb, nodered and grafana containers to the kubernetes nodes. 
The main difference here is that this project uses the kubernetes provider and deploys the k8s via terraform k8s provider
The previous deployment of nginx in the AWS2 project was done via kubectl and a yaml file.
This project uses the main.tf terraform k8s provider (basically a yaml with brackets) to deploy the containers onto the kubernetes nodes
This project also uses the terraform remote datasources.tf to pull the kubeconfig file from the AWS2 project. This is a yaml file that is
then used as the config_path in the kubernetes provider block in the providers.tf file.  Once we have this yaml file we can effectively
configure the k8s on the appropriate node as specified in the kubeconfig yaml file.  Since we have 3 deployment apps the k8s control plan
will allocate the containers between the 2 nodes in accordance with the node utlization. So the distribution of the 3 nodes is not always the same
from one terraform deploy to the next...
