# This is root/main.tf in the k8s project workspace (not AWS2 project)

# Note that this is basically a yaml file but with added braces to support terraform demarcation
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment
# Note that the host port is 8000 so we can use this with our existing AWS2 ALB loadbalancer dns address that uses tg port of 8000
# The running nginx pods running on 8000 have been destroyed!
# start out with replicas of 1
# Replicas notes: 
        # this is standard ephemeral volume (Below) that is mounted on the host itself
        # the volume is not shared like with the RDS nginx setup
        # if scale this up to 2 or more replicas best to access this through the host addresses because of this and not the ALB address
        # that is using the RDS backend database.
        
## NOTE: a for_each with a locals.tf file implementation is below this basic implementation






# ## BASIC implementation:: (this is called first-deployment.tf in the resource files for this projecct, renamed to main.tf, this file)

# resource "kubernetes_deployment" "iotdep" {
#   metadata {
#     name = "iotdep"
#     labels = {
#       app = "iotapp"
#     }
#   }

#   spec {
#     replicas = 1

#     selector {
#       match_labels = {
#         app = "iotapp"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "iotapp"
#         }
#       }

#       spec {
#         container {
#           image = "nodered/node-red:latest"
#           name  = "nodered-container"
#           volume_mount {
#             name       = "nodered-vol"
#             mount_path = "/data"
#           }
#           port {
#             container_port = 1880
#             host_port      = 8000
#             # our existing ALB loadbalancer on AWS can be used from the AWS2 project
#           }
#         }
#         volume {
#         # this is standard ephemeral volume that is mounted on the host itself
#         # the volume is not shared like with the RDS nginx setup
#         # if scale this up to 2 or more replicas best to access this through the host addresses because of this and not the ALB address
#           name = "nodered-vol"
#           empty_dir {
#             medium = ""
#           }
#         }
#       }
#     }
#   }
# }






## 3 application implementation::

## Revise the above configuration using a for_each loop in conjunction with the root/locals.tf file that was created
## in the k8s porject workspace.  This is to deploy 3 different k8s pods onto the single node 
## The use of the locals.tf file in the k8s workspace project is used below in a for_each to iterate through all 3 applications
## https://developer.hashicorp.com/terraform/language/meta-arguments/for_each

resource "kubernetes_deployment" "iotdep" {
  for_each = local.deployment
  # deployment is the name of the locals.tf map
  metadata {
    #name = "iotdep"
    name = "${each.key}-dep-app"
    # each.key  is the following from the locals.tf: nodered, influxdb, and granfana
    # this will actually be 3 different deployments (of different apps)
    labels = {
      app = "iotapp"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "iotapp"
      }
    }

    template {
      metadata {
        labels = {
          app = "iotapp"
        }
      }

      spec {
        container {
          #image = "nodered/node-red:latest"
          image = each.value.image
          
          #name  = "nodered-container"
          name = "${each.key}-container"
          # each.key will be nodered influxdb and granfana
          
          volume_mount {
            #name       = "nodered-vol"
            name = "${each.key}-vol"
            
            #mount_path = "/data"
            mount_path = each.value.volumepath
          }
          
          port {
            #container_port = 1880
            container_port = each.value.int
            # this is the internal port (container port)
            
            #host_port      = 8000
            # our existing ALB loadbalancer on AWS can be used from the AWS2 project
            host_port = each.value.ext
            # this is the external port (exposed port). This is the port that the target group of the loadblancer uses
            # Because it is no longer 8000 the ALB loadbalancer will not work with this setup
            # We will have to hit the node ip address in the browser or modify the target group of the loadbalancer in AWS for all
            # 3 ports
          }
        }
        volume {
        # this is standard ephemeral volume that is mounted on the host itself
        # the volume is not shared like with the RDS nginx setup
        # if scale this up to 2 or more replicas best to access this through the host addresses because of this and not the ALB address
          
          #name = "nodered-vol"
          name = "${each.key}-vol"
          # each.key is nodered influxdb and granfana keys into the locals mapping file locals.tf
          empty_dir {
            medium = ""
          }
        }
      }
    }
  }
}