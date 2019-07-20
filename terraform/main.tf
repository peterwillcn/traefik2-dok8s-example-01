
resource "digitalocean_tag" "kubernetes-cl01" {
  name = "kubernetes-cl01"
}

resource "digitalocean_kubernetes_cluster" "cl01" {
  name    = "cl01"
  region  = "fra1"
  version = "1.14.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 3
    tags = ["${digitalocean_tag.kubernetes-cl01.id}"]
  }
}

resource "digitalocean_loadbalancer" "kubernetes-cl01-public" {
  name = "kubernetes-cl01-public"
  region = "fra1"

  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 30101
    target_protocol = "http"
  }

  healthcheck {
    port = 30103
    protocol = "http"
    path = "/ping"
  }

  droplet_tag = "${digitalocean_tag.kubernetes-cl01.id}"
}

resource "digitalocean_firewall" "kubernetes-cl01-public" {
  name = "kubernetes-cl01-public"
  tags = ["${digitalocean_tag.kubernetes-cl01.id}"]

  inbound_rule {
    protocol = "tcp"
    port_range = "30101-30103"
    source_load_balancer_uids = ["${digitalocean_loadbalancer.kubernetes-cl01-public.id}"]
  }
}