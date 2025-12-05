variable "DO_TOKEN" {
  type      = string
  sensitive = true
}
variable "DO_REGION" {
  type    = string
  default = "sgp1"
}
variable "DO_SIZE" {
  type    = string
  default = "s-1vcpu-1gb"
}
variable "DO_IMAGE" {
  type    = string
  default = "ubuntu-24-04-x64"
}
variable "backend_count" {
  type    = number
  default = 3
}
variable "db_password" {
  type      = string
  sensitive = true

}