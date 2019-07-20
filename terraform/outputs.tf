output "kubeconfig" {
  value = "${digitalocean_kubernetes_cluster.cl01.kube_config.0.raw_config}"
}
