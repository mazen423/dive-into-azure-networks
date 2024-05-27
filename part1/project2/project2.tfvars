rg_name = "project2"
location = "westeurope"
vnet_cidr = ["172.16.0.0/16"]
subnets = {
    main            = ["172.16.0.0/24"]
}

vms = {
    main = {
        subnet = "main"
        public_ip = false
    }
}
remote_virtual_network_id = ""
