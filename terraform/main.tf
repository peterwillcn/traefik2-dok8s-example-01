
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

resource "digitalocean_certificate" "stepanvrany-cz" {
  name    = "le-stepanvrany-cz"
  type    = "lets_encrypt"
  domains = ["admin.stepanvrany.cz", "stepanvrany.cz"]
}

resource "digitalocean_loadbalancer" "kubernetes-cl01-public" {
  name = "kubernetes-cl01-public"
  region = "fra1"
  enable_proxy_protocol = true
  redirect_http_to_https = false

  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 30101
    target_protocol = "http"
  }

  forwarding_rule {
    entry_port = 443
    entry_protocol = "https"

    target_port = 30101
    target_protocol = "http"
    certificate_id  = "${digitalocean_certificate.stepanvrany-cz.id}"
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

resource "digitalocean_record" "admin-stepanvrany-cz" {
  domain = "${data.digitalocean_domain.stepanvrany-cz.name}"
  type   = "A"
  name   = "admin"
  value  = "${digitalocean_loadbalancer.kubernetes-cl01-public.ip}"
}