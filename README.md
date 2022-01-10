# Bioconductor Helm Chart
This Helm chart can in principle be used to deploy any container image built on top of [`rocker/rstudio`](https://hub.docker.com/r/rocker/rstudio), but is notably pre-configured for Bioconductor's [`bioconductor_docker`](https://github.com/Bioconductor/bioconductor_docker) image.

In order to use this Helm chart, you will need `kubectl` ([how to install](https://kubernetes.io/docs/tasks/tools/#kubectl))
and `Helm` ([how to install](https://helm.sh/docs/intro/install/)) installed.

### Helm Basics
A packaged version of this chart can be found in the [Bioconductor Helm Charts repository](https://github.com/Bioconductor/helm-charts).

For all below examples, this helm chart can be deployed from source:
```bash
git clone https://github.com/bioconductor/bioconductor-helm
helm install myrelease ./bioconductor-helm/bioconductor

```

Or from the packaged repository:
```bash
helm repo add bioc https://github.com/Bioconductor/helm-charts/raw/main
helm install myrelease bioc/bioconductor

```

For more information on `helm install` options, see the [Helm documentation](https://helm.sh/docs/helm/helm_install/).


## Deployment examples
This Helm chart can theoretically be run on any Kubernetes cluster. Below are a few tested example deployments.

### Deploy locally with `minikube`
Follow the [minikube documentation](https://minikube.sigs.k8s.io/docs/start/) to install minikube for your operating system.


#### Starting the deployment

1. Start `minikube` cluster
```bash
minikube start
```

2. Helm install chart with example configuration file

Note: This configuration notably has RStudio running with no authentication, and no persistence; it is therefore only recommended for transient local installations and development

```bash
helm install mybioc bioconductor-helm/bioconductor -f bioconductor-helm/examples/minikube-vals.yaml
```

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

4. Print `minikube` IP and exposed port

Once the deployment is ready, you can now access RStudio at the minikube IP.
```bash
echo $(minikube ip):$(kubectl get -o jsonpath="{.spec.ports[0].nodePort}" services mybioc-bioconductor)
```

5. Access the local IP address and port in a web browser

RStudio should be running at the local IP address and port printed by the command above.

#### Stopping the deployment

1. Delete Helm release
```bash
helm delete mybioc
```

2. Stop minikube
```bash
minikube stop
```