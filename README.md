# "Hello World" on OpenShift
Application container images built and deployed using OpenShift practices are fully Kubernetes compliant and can be deployed to any k8s cluster. This walkthrough demonstrates some of those OpenShift best practices that result in secure and well managed deployments fit for operating in an enterprise environment.

## Walkthrough
### [1. Build and Run a Local Hello World application](walkthrough/1-hello-world-begin.md)

To introduce the concepts and foundations within OpenShift we are going to start with some simple source and tests of a NodeJS application. 

### [2. Local Podman Build and Run](walkthrough/2-local-podman-build-and-run.md)
The installation and configuration of Podman and how to build and run a container image.

### [3. OpenShift Local](walkthrough/3-openshift-local.md)
Introduction to Red Hat OpenShift Local was previously known as Code Ready Containers and configuration with Podman. 

### [4. Deploy Local Image to OpenShift Local](walkthrough/4-deploy-local-image-to-openshift.md)
Deployment and run of images in OpenShift Local and description of OpenShift optimised Dockerfile.

### [5. Configure Pod Security](walkthrough/5-configure-pod-security.md)
Adding OpenShift pod security to harden a deployment for real-world use.

### [6. Using Templates](walkthrough/6-using-templates.md)
OpenShift Template are a starting point for creating all encompassing build and deployment of OpenShift applications.

### [7. Vanilla Kubernetes](walkthrough/7-vanilla-kubernetes.md)
We can demonstrate that the OpenShift container build and execution are 100% Kubernetes specification compliant.

![security scan image](/images/security-scan.png)

## References
- [Red Hat OpenShift Local site](https://developers.redhat.com/products/openshift-local/overview)
- [Best practices for building images for Kubernetes and OpenShift](https://developer.ibm.com/learningpaths/universal-application-image/design-universal-image/)
- [Pod Security](https://developer.ibm.com/learningpaths/secure-context-constraints-openshift/scc-tutorial/)
- [Minikube](https://minikube.sigs.k8s.io/docs/)







