data "digitalocean_ssh_key" "fred" {
  name = "fred"
}

resource "digitalocean_droplet" "mydroplet" {
  name     = "mydroplet"
  image    = var.DO_IMAGE
  region   = var.DO_REGION
  size     = var.DO_SIZE
  ssh_keys = [data.digitalocean_ssh_key.fred.id]

  provisioner "file" {
    source      = "${path.module}/workshop01_nginx_assets.zip"
    destination = "/tmp/workshop01_nginx_assets.zip"

    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = file(var.ssh_private_key_path)
    }
  }

  # 2) Move into /var/www/html and replace the IP placeholder
  provisioner "remote-exec" {
    inline = [
      "apt update",
      "apt install -y nginx unzip",
      "systemctl daemon-reload",
      "systemctl enable nginx",
      "systemctl start nginx",
      "apt update && apt install -y unzip",
      "mkdir -p /tmp/workshop01_nginx_assets",
      "unzip -o /tmp/workshop01_nginx_assets.zip -d /tmp/workshop01_nginx_assets",
      "cp -r /tmp/workshop01_nginx_assets/* /var/www/html/",
      "sed -i 's/Droplet IP address here/${self.ipv4_address}/g' /var/www/html/index.html"
    ]

    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = file(var.ssh_private_key_path)
    }
  }
}

