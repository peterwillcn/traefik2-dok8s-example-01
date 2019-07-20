# Traefik 2 beta vs. DOK8 demo

## prerequisites
- Terraform (I was using `v0.11.14`)
- Kubectl
- DigitalOcean token with write permissions
- Domain managed by DigitalOcean DNS service

## getting started

**Edit domain name in Terraform manifests**
This example is using [Let's Encrypt certificate](https://www.terraform.io/docs/providers/do/r/certificate.html#domains) so used domain name 
must be managed by DigitalOcean.

**Create the base infrastructure:**

```bash
cd terraform
export TF_VAR_do_token=<your DO token>
terraform init
terraform plan
terraform apply -auto-approve
```

**Create kube config:**

```bash
terraform output -json | jq -r '.kubeconfig.value' > kubeconfig.yaml
export KUBECONFIG=$(pwd)/kubeconfig.yaml
```

**Create Kubernetes resources**

```bash
cd ../kubernetes/traefik
kubectl apply -f crds.yaml
kubectl apply -f sa.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f service-admin.yaml
```
