terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
data "docker_registry_image" "ghost_ri" {
  name = var.image_name
}
resource "docker_image" "ghost_image" {
  name          = data.docker_registry_image.ghost_ri.name
  pull_triggers = [data.docker_registry_image.ghost_ri.sha256_digest]
}
resource "docker_container" "ghost_container" {
  name  = var.container_name
  image = docker_image.ghost_image.latest
  ports {
    internal = "2368"
    external = var.ext_port
  }
}
