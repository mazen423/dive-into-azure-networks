rg_name = "project1"
location = "westeurope"
vnet_cidr = ["10.0.0.0/16"]
subnets = {
    frontend            = ["10.0.10.0/24"]
    backend             = ["10.0.20.0/24"]
    AzureBastionSubnet  = ["10.0.30.0/24"]
}

vms = {
    frontend = {
        subnet = "frontend"
        public_ip = true
    }
    backend = {
        subnet = "backend"
        public_ip = false
    }
}
nsgs = {
    frontend-nsg = {
        subnet = "frontend"
        rules = {
            default_deny = {
                priority  = 4096
                direction = "Inbound"
                protocol  = "*"
                access    = "Deny"
                source = {
                  port_range = "*"
                  ip_range   = "*"
                    }
                destination = {
                  port_range = "*"
                  ip_range   = "*"
                }
            }
            http_allow_internet = {
                priority  = 4090
                direction = "Inbound"
                protocol  = "Tcp"
                access    = "Allow"
                source = {
                  port_range = "*"
                  ip_range   = "*"
                    }
                destination = {
                  port_range = "80"
                  ip_range   = "10.0.10.0/24"
                }
            }
            ssh_allow_bastion = {
                priority  = 4080
                direction = "Inbound"
                protocol  = "Tcp"
                access    = "Allow"
                source = {
                  port_range = "*"
                  ip_range   = "10.0.30.0/24"
                    }
                destination = {
                  port_range = "22"
                  ip_range   = "10.0.10.0/24"
                }
            }
           
        }
    }

    backend-nsg = {
        subnet = "backend"
        rules = {
            default_deny = {
                priority  = 4096
                direction = "Inbound"
                protocol  = "*"
                access    = "Deny"
                source = {
                  port_range = "*"
                  ip_range   = "*"
                    }
                destination = {
                  port_range = "*"
                  ip_range   = "*"
                }
            }
            http_allow_frontend = {
                priority  = 4090
                direction = "Inbound"
                protocol  = "Tcp"
                access    = "Allow"
                source = {
                  port_range = "*"
                  ip_range   = "10.0.10.0/24"
                    }
                destination = {
                  port_range = "80"
                  ip_range   = "10.0.20.0/24"
                }
            }
            ssh_allow_bastion = {
                priority  = 4080
                direction = "Inbound"
                protocol  = "Tcp"
                access    = "Allow"
                source = {
                  port_range = "*"
                  ip_range   = "10.0.30.0/24"
                    }
                destination = {
                  port_range = "22"
                  ip_range   = "10.0.20.0/24"
                }
            }
           
        }
    }
}
