
variable "availability_zone" {
  default = "us-east-1b"
}

variable "ssh_public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAxpgo8+kKJg6NyqDRNY5Ldcmh7zaflHyubyA2dA+Cl3GT2Jbu+QBmGqpnkz5uO5Ad9outmvPbUXOc2czQ8vhXfOIK4qqwYwQgx928JtPENqM9vKMmsuI4VbdMZETOOxc8bUdCluvF4tC1gIbvODakc9hd8UgFVo+JZauKQ7NqsJ9pmNS0momg5LjQo6uten03rU1xn+iJZNmMUnvrETiYaYIhnYOT7r6mfeg5wWY3htBIdbjkwCEUE44ZPrxXW24SsnyZFH0JBQSYt9DxCAh4KYU+Eugs9HtjH/XLHhLCYHOOdwXkELRwLwwAPuLK/xA+rW7u6GErBd9axsMAFhJ2UQ== Dylan M. Taylor"
}

variable "ssh_key_name" {
  default = "Dylan Taylor"
}

variable "instance_flavor" {
  default = "t4g.nano"
}