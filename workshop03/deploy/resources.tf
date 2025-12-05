data "digitalocean_image" "code-server-image" {
  name =  "my-code-server"
}

data "digitalocean_ssh_key" "fred" {
  name = "fred"
}

resource "digitalocean_droplet" "mydroplet" {
  name   = "mydroplet"
  image  = data.digitalocean_image.code-server-image.id
  region = var.DO_REGION
  size   = var.DO_SIZE
  ssh_keys = [ data.digitalocean_ssh_key.fred.id ]

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's|PASSWORD=__REPLACE__|PASSWORD=${var.code_server_password}|' /lib/systemd/system/code-server.service",

      "sudo systemctl daemon-reload",
      "sudo systemctl restart code-server",

      "sudo sed -i 's|server_name .*;|server_name code-${self.ipv4_address}.nip.io;|' /etc/nginx/sites-available/code-server.conf",

      "sudo systemctl restart nginx"
    ]

    connection {
      host        = self.ipv4_address
      user        = "root"
      private_key = file("/home/fred/.ssh/id_ed25519_fred")
    }
  }
}

output "fred_ssh_key_finger_print" {
  value = data.digitalocean_ssh_key.fred.fingerprint
}

output "mydroplet_ipv4" {
    value = digitalocean_droplet.mydroplet.ipv4_address
  
}

