data "digitalocean_ssh_key" "fred" {
  name = "fred"
}

resource "digitalocean_droplet" "mydroplet" {
  name   = "mydroplet"
  image  = var.DO_IMAGE
  region = var.DO_REGION
  size   = var.DO_SIZE
  ssh_keys = [ data.digitalocean_ssh_key.fred.id ]
}

resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/inventory.yaml"
  file_permission = "0644"

  content = templatefile("${path.module}/inventory.yaml.tftpl", {
    droplet_ip                  = digitalocean_droplet.mydroplet.ipv4_address
    ansible_ssh_private_key_file = "/home/fred/.ssh/id_ed25519_fred"
    code_server_password         = var.code_server_password
  })
}

output "fred_ssh_key_finger_print" {
  value = data.digitalocean_ssh_key.fred.fingerprint
}

output "mydroplet_ipv4" {
    value = digitalocean_droplet.mydroplet.ipv4_address
  
}

