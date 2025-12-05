source "digitalocean" "mydroplet" {
  api_token    = var.DO_TOKEN
  image        = "ubuntu-24-04-x64"
  size         = "s-2vcpu-4gb"
  region       = "sgp1"
  ssh_username = "root"
  snapshot_name = "my-code-server"
}

build {
  sources = [
    "source.digitalocean.mydroplet"
  ]

  provisioner "ansible" {
    playbook_file = "code-server.yaml"
  }

  provisioner "ansible" {
    playbook_file = "nginx-code-server.yaml"
  }
}