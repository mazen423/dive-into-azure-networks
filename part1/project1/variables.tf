variable "rg_name" {
  type = string

}

variable "location" {
  type = string
}

variable "vnet_cidr" {
  type = list(string)
}

variable "subnets" {
  type = map(list(string))
}

variable "vms" {
  type = any
}

variable "nsgs" {
  type = any
}
