terraform {
  required_version = "1.14.1"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.6.1"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.69.0"
    }
  }
}

provider "local" {

}

provider "digitalocean" {
  # Configuration options
  token = var.DO_TOKEN
}