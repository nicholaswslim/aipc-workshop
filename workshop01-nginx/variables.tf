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
variable "ssh_private_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519_fred"

}