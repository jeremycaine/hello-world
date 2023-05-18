# 7. Vanilla Kubernetes
We can demonstrate that the OpenShift container build and execution are 100% Kubernetes specification compliant.

Red Hat OpenShift is the supported product from the downstream open source OKD. OKD itself is a continually maintained fork of Kubernetes with additional build and deployment tools, including custom resource definitions - all designed to improve the overall experience of Kubernetes development. The wider OpenShift ecosystem is a collection of other supported products based on open source projects e.g. OpenShift Pipelines for Tekton abd OpenShift GitOps for ArgoCD.

We will conclude by demonstrating this compatability.

## 7.1 Push Images to Quay
We will build both the simple container image and the one optimised for OpenShift and push them into your Quay.io registry
```
podman images

# log in to the registry
podman login quay.io -u jeremycaine -p ...

# build the image using the simple Dockerfile not optimised for OpenShift
cp ./src/Dockerfile.simple ./Dockerfile
podman build -t hello-world:simple .
podman images

# push it into the Quay registry
podman push localhost/hello-world:simple quay.io/jeremycaine/hello-world:simple

# in case you need to recreate, build the OpenShift optimised container image
cp ./src/Dockerfile.openshift ./Dockerfile
podman build -t hello-world:openshift .
podman push localhost/hello-world:openshift quay.io/jeremycaine/hello-world:openshift
```

When you visit Quay.io you will see both images in your repo and one thing to note is the results of the automatic security vulnerability scans.


## 7.2. Install minikube
[Minikube](https://minikube.sigs.k8s.io/docs/) is a simple way to get a local vanilla Kubernetes cluster up and running locally.

It will automatically download the VM boot images and Kubernetes version it needs. It is unrelated to the OpenShift Local install. Because you have `podman` installed, `minikube` will automatically.

Since we are logged in to CRC the kubectl context is pointing to the project of the current `oc` session. So we need to switch context to `minikube` once it is up and running.
```
brew install minikube
minikube start
minikube status
minikube dashboard
kubectl config use-context minikube
```

Now we are going to deploy the OpenShift `hello-world` image from the Quay repository. 
```
kubectl create deployment hello-minikube --image=quay.io/jeremycaine/hello-world:openshift
kubectl expose deployment hello-minikube --type=NodePort --port=3000
kubectl get services hello-minikube
kubectl port-forward service/hello-minikube 3001:3000
```

Now when you `curl localhost:3001` it returns the Hello World message. The OpenShift optimised container - and 100% Kubernetes compliant - image is running in the vanilla Kubernetes runtime of `minikube`.


| Previous        | Next          |
| ------------- | -------------|
|[6. Using Templates](6-using-templates.md) | [Back to README](../README.md)|
