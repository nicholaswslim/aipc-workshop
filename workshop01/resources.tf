resource "docker_network" "bgg_net" {
  name = "bgg-net"
}

resource "docker_volume" "data_vol" {
  name = "data_vol"
}

resource "docker_image" "bgg_database_image" {
  name = "chukmunnlee/bgg-database:nov-2025"
}

resource "docker_container" "bgg_database" {
  image = docker_image.bgg_database_image.image_id
  name  = "bgg-database"
  networks_advanced {
    name = docker_network.bgg_net.name
  }

  mounts {
    target = "/var/lib/mysql"
    source = docker_volume.data_vol.name
    type   = "volume"
  }

  ports {
    internal = 3306
  }
}

resource "docker_image" "bgg_backend_image" {
  name = "chukmunnlee/bgg-app:nov-2025"
}

resource "docker_container" "bgg_backend" {
  count = var.backend_count

  name  = "bgg-backend-${count.index}"
  image = docker_image.bgg_backend_image.image_id

  networks_advanced {
    name = docker_network.bgg_net.name
  }

  env = [
    "BGG_DB_USER=root",
    "BGG_DB_PASSWORD=${var.db_password}",
    "BGG_DB_HOST=${docker_container.bgg_database.name}",
  ]

  # Internal app port is 3000; we bind to 3001, 3002, 3003 on your Mac
  # ports {
  #   internal = 5000
  #   external = 3001 + count.index
  # }

  # Make sure DB container is up first
  depends_on = [docker_container.bgg_database]
}

resource "local_file" "nginx_conf" {
  filename        = "nginx.conf"
  file_permission = "0444"
  content = templatefile("nginx.conf.tftpl", {
    bggapp_names = docker_container.bgg_backend[*].name,
    bggapp_port  = 5000
  })

}

# Pull nginx image
resource "docker_image" "nginx_image" {
  name = "nginx:alpine"
}

# Run nginx container
resource "docker_container" "bgg_nginx" {
  name  = "bgg-nginx"
  image = docker_image.nginx_image.image_id

  # Put nginx in the same network as the app + DB
  networks_advanced {
    name = docker_network.bgg_net.name
  }

  # Bind-mount the generated nginx.conf into the container
  volumes {
    host_path      = abspath("${path.module}/nginx.conf")
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }

  # Expose nginx on your Mac as http://localhost:8080
  ports {
    internal = 80
    external = 8080
  }

  # Make sure backends exist before nginx starts
  depends_on = [
    docker_container.bgg_backend,
  ]
}