terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "davidpeachme" {
  name       = "davidpeachme"
  public_key = file("/home/david/.ssh/id_rsa.davidpeachme.pub")
}

resource "digitalocean_droplet" "davidpeachme" {
  image    = "ubuntu-22-10-x64"
  name     = "davidpeach.me"
  region   = "lon1"
  size     = "s-1vcpu-1gb"
  ssh_keys = [digitalocean_ssh_key.davidpeachme.fingerprint]
}

data "digitalocean_domain" "davidpeachme" {
  name = "davidpeach.me"
}

resource "digitalocean_record" "davidpeachme" {
  domain = data.digitalocean_domain.davidpeachme.id
  type   = "A"
  name   = "@"
  ttl    = 60
  value  = "${digitalocean_droplet.davidpeachme.ipv4_address}"
}
