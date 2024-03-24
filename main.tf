terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}

# Variables whose values are defined in ./terraform.tfvars
variable "domain_name" {}
variable "droplet_image" {}
variable "droplet_name" {}
variable "droplet_region" {}
variable "droplet_size" {}
variable "ssh_key_name" {}
variable "ssh_local_path" {}
variable "a_record_name" {}
variable "a_record_name_zet" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "ssh_key" {
  name       = var.ssh_key_name
  public_key = file(var.ssh_local_path)
}

resource "digitalocean_droplet" "droplet" {
  image    = var.droplet_image
  name     = var.droplet_name
  region   = var.droplet_region
  size     = var.droplet_size
  ssh_keys = [digitalocean_ssh_key.ssh_key.fingerprint]
}

data "digitalocean_domain" "domain" {
  name = var.domain_name
}

resource "digitalocean_record" "record" {
  domain = data.digitalocean_domain.domain.id
  type   = "A"
  name   = var.a_record_name
  ttl    = 60
  value  = "${digitalocean_droplet.droplet.ipv4_address}"
}

resource "digitalocean_record" "record_zet" {
  domain = data.digitalocean_domain.domain.id
  type   = "A"
  name   = var.a_record_name_zet
  ttl    = 60
  value  = "${digitalocean_droplet.droplet.ipv4_address}"
}

output "droplet_id_v4_address" {
  value = digitalocean_droplet.droplet.ipv4_address
}

