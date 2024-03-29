# Bioconductor Helm Chart
This Helm chart can in principle be used to deploy any container image built on top of [`rocker/rstudio`](https://hub.docker.com/r/rocker/rstudio), but is notably pre-configured for Bioconductor's [`bioconductor_docker`](https://github.com/Bioconductor/bioconductor_docker) image.

In order to use this Helm chart, you will need `kubectl` ([how to install](https://kubernetes.io/docs/tasks/tools/#kubectl))
and `Helm` ([how to install](https://helm.sh/docs/intro/install/)) installed.

## Helm Basics
A packaged version of this chart can be found in the [Bioconductor Helm Charts repository](https://github.com/Bioconductor/helm-charts).

For all below examples, this helm chart can be deployed from source:
```bash
git clone https://github.com/bioconductor/bioconductor-helm
helm install myrelease ./bioconductor-helm/bioconductor

```

Or from the packaged repository:
```bash
helm repo add bioc https://github.com/Bioconductor/helm-charts/raw/devel
helm install myrelease bioc/bioconductor

```

For more information on `helm install` options, see the [Helm documentation](https://helm.sh/docs/helm/helm_install/).

---

# Deployment examples
This Helm chart can theoretically be run on any Kubernetes cluster. Below are a few tested example deployments.

| Example deployments |
| ------------------ |
| [Local minikube](https://github.com/Bioconductor/bioconductor-helm#deploy-locally-with-minikube) |
| [MS Azure AKS](https://github.com/Bioconductor/bioconductor-helm#deploy-on-the-microsoft-azure-cloud-on-an-aks-cluster) |
| [Google Kubernetes Engine](https://github.com/Bioconductor/bioconductor-helm#deploy-on-google-cloud-on-a-gke-cluster) |
| [Amazon Web Services' Elastic Kubernetes Service](https://github.com/Bioconductor/bioconductor-helm#deploy-on-amazon-web-services-on-an-eks-cluster) |

---

## Deploy locally with `minikube`
Follow the [minikube documentation](https://minikube.sigs.k8s.io/docs/start/) to install minikube for your operating system.


### Starting the deployment

1. Start `minikube` cluster
```bash
minikube start
```
---

2. Helm install chart with example configuration file

Note: This configuration notably has RStudio running with no authentication, and no persistence; it is therefore only recommended for transient local installations and development.

```bash
helm install mybioc bioconductor-helm/bioconductor -f bioconductor-helm/examples/minikube-vals.yaml
```
---

3. Check status of pods and wait until it is up and healthy

If this is your first time running the chart, keep in mind that it will take a few minutes for the container images to be pulled and extracted.
```bash
# See pods status
kubectl get pods
# See recent events
kubectl get events
# Wait until the deployment is ready
kubectl wait --for=condition=available --timeout=600s deployment/mybioc-bioconductor

```
---

4. Print `minikube` IP and exposed port

Once the deployment is ready, you can now access RStudio at the minikube IP.
```bash
echo $(minikube ip):$(kubectl get -o jsonpath="{.spec.ports[0].nodePort}" services mybioc-bioconductor)
```
---

5. Access the local IP address and port in a web browser

RStudio should be running at the local IP address and port printed by the command above.

---

### Stopping the deployment

1. Delete Helm release
```bash
helm delete mybioc
```

2. Stop minikube
```bash
minikube stop
```

---

## Deploy on the Microsoft Azure cloud on an `AKS` cluster
This assumes that you have the `Azure CLI` installed ([how to install](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos)),  that you are authenticated ([how to authenticate](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli)), and have proper permissions.


### Starting the deployment

1. Start `AKS` cluster

If you prefer to launch the AKS cluster from the web portal, or already have an existing cluster, you can skip to step 2.
```bash
az aks create --resource-group mypersonalrg --name my-aks-cluster --node-count 1
```

---

2. Point the kubeconfig context to the AKS cluster

```bash
az aks get-credentials --resource-group mypersonalrg --name my-aks-cluster
```

---

3. Helm install chart with example configuration file

This configuration notably has RStudio running with a hardcoded password. Since your cluster will be publicly available on the internet, it is recommended you change the password in this file.

This example also uses a 10Gi Azure standard SSD disk for persistence. This solution will not work well with multi-node clusters, as it is a `ReadWriteOnce` storage class, but will work on single-node clusters as is the one launched in this example.

```bash
helm install mybioc bioconductor-helm/bioconductor -f bioconductor-helm/examples/aks-vals.yaml
```

---

4. Check status of pods and wait until it is up and healthy

If this is your first time running the chart, keep in mind that it will take a few minutes for the container images to be pulled and extracted.
```bash
# See pods status
kubectl get pods
# See recent events
kubectl get events
# Wait until the deployment is ready
kubectl wait --for=condition=available --timeout=600s deployment/mybioc-bioconductor

```

---

4. Print LoadBalancer IP

Once the deployment is ready, you can now access RStudio at the LoadBalancer IP.
```bash
echo $(kubectl get svc mybioc-bioconductor --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
```

---

5. Access the public IP address in a web browser

RStudio should be running at the public IP address printed by the command above.

By default, you can login with user `rstudio` and the password you provided in the values file.

---

### Stopping the deployment

1. Delete Helm release
```bash
helm delete mybioc
```

---

2. Delete the AKS cluster

Note: You will be prompted for confirmation. Also keep in mind that the `default` storage class in AKS sets disks to be deleted with their corresponding persistent volumes in AKS, so all your data will be deleted.

```bash
az aks delete --resource-group mypersonalrg --name my-aks-cluster 
```


---

## Deploy on Google Cloud on a `GKE` cluster
This assumes that you have the `Google Cloud SDK` installed ([how to install](https://cloud.google.com/sdk/docs/install#installation_instructions)), that you are authenticated ([how to authenticate](https://cloud.google.com/sdk/docs/install#installation_instructions)), and have proper permissions.


### Starting the deployment

1. Start `GKE` cluster

If you prefer to launch the GKE cluster from the web portal, or already have an existing cluster, you can skip to step 2.
```bash
gcloud container clusters create my-gke-cluster --disk-size=100 --num-nodes=1 --machine-type=e2-medium --zone us-east1-b
```

---

2. Point the kubeconfig context to the GKE cluster (if you launched the cluster in the CLI, the Google Cloud SDK will have already switched the context)

```bash
gcloud container clusters get-credentials my-gke-cluster --zone us-east1-b
```

---

3. Helm install chart with example configuration file

This configuration notably has RStudio running with a hardcoded password. Since your cluster will be publicly available on the internet, it is recommended you change the password in this file.

This example also uses a 10Gi Google standard SSD disk for persistence. This solution will not work well with multi-node clusters, as it is a `ReadWriteOnce` storage class, but will work on single-node clusters as is the one launched in this example.

```bash
helm install mybioc bioconductor-helm/bioconductor -f bioconductor-helm/examples/gke-vals.yaml
```

---

4. Check status of pods and wait until it is up and healthy

If this is your first time running the chart, keep in mind that it will take a few minutes for the container images to be pulled and extracted.
```bash
# See pods status
kubectl get pods
# See recent events
kubectl get events
# Wait until the deployment is ready
kubectl wait --for=condition=available --timeout=600s deployment/mybioc-bioconductor

```

---

4. Print LoadBalancer IP

Once the deployment is ready, you can now access RStudio at the LoadBalancer IP.
```bash
echo $(kubectl get svc mybioc-bioconductor --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
```

---

5. Access the public IP address in a web browser

RStudio should be running at the public IP address printed by the command above.

By default, you can login with user `rstudio` and the password you provided in the values file.

---

### Stopping the deployment

1. Delete Helm release
```bash
helm delete mybioc
```

---

2. Delete the GKE cluster

Note: You will be prompted for confirmation. Also keep in mind that the `default` storage class in GKE sets disks to be deleted with their corresponding persistent volumes in GKE, so all your data will be deleted.

```bash
gcloud container clusters delete my-gke-cluster --zone us-east1-b 
```

---

## Deploy on Amazon Web Services on an `EKS` cluster
This assumes that you have `eksctl` installed ([how to install](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)), and that you have [proper IAM permissions](https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonelastickubernetesservice.html).


### Starting the deployment

1. Start `EKS` cluster

If you prefer to launch the EKS cluster from the web portal, or already have an existing cluster, you can skip to step 2.
```bash
eksctl create cluster --name=my-cluster --nodes=1 --node-volume-size=100 
```

---

2. Point the kubeconfig context to the EKS cluster (if you launched the cluster in the CLI, the context should have been switched by the create command)

```bash
eksctl utils write-kubeconfig --cluster=my-cluster
```

---

3. Helm install chart with example configuration file

This configuration notably has RStudio running with a hardcoded password. Since your cluster will be publicly available on the internet, it is recommended you change the password in this file.

This example also uses a 10Gi Google standard SSD disk for persistence. This solution will not work well with multi-node clusters, as it is a `ReadWriteOnce` storage class, but will work on single-node clusters as is the one launched in this example.

```bash
helm install mybioc bioconductor-helm/bioconductor -f bioconductor-helm/examples/eks-vals.yaml
```

---

4. Check status of pods and wait until it is up and healthy

If this is your first time running the chart, keep in mind that it will take a few minutes for the container images to be pulled and extracted.
```bash
# See pods status
kubectl get pods
# See recent events
kubectl get events
# Wait until the deployment is ready
kubectl wait --for=condition=available --timeout=600s deployment/mybioc-bioconductor

```

---

4. Print LoadBalancer IP

Once the deployment is ready, you can now access RStudio at the LoadBalancer IP.
```bash
echo $(kubectl get svc mybioc-bioconductor --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
```

---

5. Access the public IP address in a web browser

RStudio should be running at the public IP address printed by the command above.

By default, you can login with user `rstudio` and the password you provided in the values file.

---

### Stopping the deployment

1. Delete Helm release
```bash
helm delete mybioc
```

---

2. Delete the EKS cluster

```bash
eksctl delete cluster --name=my-cluster
```
