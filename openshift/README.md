# OpenShift
Walkthrough of building the app from source and deploying to an OpenShift cluster using the `oc new-app` process.

## 1. OpenShift Cluster
For OpenShift Local
```
crc start
crc start -c 8 -m 16384
```

Login to OpenShift Cluster e.g. as `developer` for OpenShift Local
```
eval $(crc oc-env)
oc login -u developer https://api.crc.testing:6443
```

## 2. Create the Deployment
The simple `hello-world` app in [repo](https://github.com/jeremycaine/hello-world) is a web app lisenting on port 3000 
```
# Create a new project
oc new-project hello-world

# not using nodejs~https://github.com/jeremycaine/hello-world.git
# detects EXPOSE in Dockerfile and sets Target Port in Route (which is the port the app in container is lisenting on)
cd ...path.../hello-world
oc new-app .

error:

oc new-app .
warning: Cannot check if git requires authentication.
W0406 17:21:06.621011    1991 dockerimagelookup.go:297] container image remote registry lookup failed: registry.access.redhat.com/ubi9/nodejs-16-minimal:latest: Get "https://registry.access.redhat.com/v2/": dial tcp: lookup registry.access.redhat.com on 10.217.4.10:53: server misbehaving
error: unable to locate any images in image streams, local docker images with name "registry.access.redhat.com/ubi9/nodejs-16-minimal"
```

crc console
Home > Detail > view settings > (cluster settings) Configuration > Image > YAML
```
...
spec:
  additionalTrustedCA:
    name: registry-certs
  allowedRegistriesForImport:
    - domainName: registry.access.redhat.com
      insecure: false
  registrySources:
    allowedRegistries:
      - registry.access.redhat.com
      - 'image-registry.openshift-image-registry.svc:5000'
...
```

## try again
```
oc new-app .
oc expose service/hello-world
oc status
curl http://hello-world-hello-world.apps-crc.testing

oc logs -f deployment/hello-world

# creates the following:
# Namespace = hello-node (Kubenetes spec)
# Service = hello-node (Kubernetes spec)
# Deployment = hello-node (Kubernetes spec)
# plus OpenShift spins up the pods, and creates necessary ConfigMaps (Kubernetes spec)
```

### `oc new-app` build strategy

*Type of Build* - Source or Docker

if new-app finds a Dockerfile, then build strategy is Docker
a Docker build strategy invokes plain Docker build

`--strategy=(docker|source)`

Specify the build strategy to use if you don't want to detect (note: pipepline option is deprecated)

```
oc new-project hello-node
oc new-app https://github.com/cg2p/hello-node.git --strategy=source
```

## 3. Expose access to the app
If the Dockerfile has EXPOSE set, then the `oc new-app` build and deploy detects and the Service/hello-node will load balance against that exposed port (which is what the NodeJS server code is listening on).

EXPOSE is not mandatory but helps setup for inter-container communication, but also serves as a description that processes like `oc new-app` can use to generate the deploymeny.

If the Dockerfile EXPOSE is not set then
```
# if Dockerfile EXPOSE is NOT set then
oc expose dc/hello-node --port=3000
```

Now create a Route to expose the Service/hello-node
```
# --name sets the name of the Route that is created
# Route = hello-node-route (OpenShift spec)
oc expose svc/hello-node --name=hello-node-route 
```

Then get the URL the service is available on
```
oc status 
```

Returns the URL of the exposed app to call via browser or curl
```
> In project hello-node on server https://url-of-your-openshift-cluster
> http://url-of-the-route-to-your-app to pod port 3000-tcp (svc/hello-node)
  dc/hello-node deploys istag/hello-node:latest <-
    bc/hello-node docker builds https://github.com/cg2p/hello-node.git on istag/node:10-alpine 
    deployment #1 deployed 6 minutes ago - 1 pod
curl http://url-of-the-route-to-your-app 
> Hello World !
```

## 4. Templates
A basic NodeJS OpenShift template. The app server looks for two environment variables:
- MYVISIBLEVAR is set on the `oc new-app` build and deploy action.
- MYSECRETVAR is set via the kubernetes Secret

The secret is created and applied to the DeploymentConfig causing the pods to restart and pick up the Secret and then the env var.
```
oc new-project hello2
oc new-app -f ./hello-node-template.json \
    -p NAME=hello2 -p MYVISIBLEVAR=amazing -p SERVER_PORT=3000
oc create secret generic hello2-secret --from-literal=MYSECRETVAR=MyBigSecret
oc set env --from=secret/hello2-secret dc/hello2
```

Templates give you the opportunity to set up specifics for your application that get created in its project. This include specifics around how the app is built and image management and build triggers.

## 5. Understanding the CRDs
Objects of Kubernetes and OpenShift specific CRD types created during `oc new-app` inner loop process.
```
// create OpenShift project and it creates Kubernetes namespace and sets context to
oc new-project hello3
# Namespace = hello3 (Kubenetes spec)
// kubectl get all -n hello3
// or
oc get all 
> No resources found in hello3 namespace.
// create the app
oc new-app https://github.com/cg2p/hello-node.git
oc expose svc/hello-node
oc get all
```
For the project (which selects namespace) `oc get all` returns list of all Kubernetes objects

Kubernetes CRD
- `pod/hello-node-1-build` (executes the build and completes)
- `pod/hello-node-NNNNNN-AAAA` (executes the app)
- `service/hello-node` (load balances across the port exposed by app e.g. 3000)
- `deployment.apps/hello-node` (autogenerated to create deployment description e.g. #replicas)
- `replicaset.apps/hello-node-NNNNNN` (number of desired pods of same name as described in deployment.apps)

OpenShift CRD
- `buildconfig.build.openshift.io/hello-node` (configuration for build from git repo - default Docker - and setup ImageStream)
- `build.build.openshift.io/hello-node-1` (runs build and points ImageStream to it)
- `imagestream.image.openshift.io/node` (points to base image from OpenShift Registry from which to build app)
- `imagestream.image.openshift.io/hello-node` (points to image of app built and stored in registr)
- `route.route.openshift.io/hello-node` (setups load balanced access to service with additional security and traffic management features)


## References
- [Kubernetes Ingress vs OpenShift Route](https://www.openshift.com/blog/kubernetes-ingress-vs-openshift-route)

- [ImageStream benefits explaination](https://cloudowski.com/articles/why-managing-container-images-on-openshift-is-better-than-on-kubernetes/)

- [Understanding containers, images, and imagestreams](https://docs.openshift.com/container-platform/4.6/openshift_images/images-understand.html)

- Example template file for `oc new-app` for [Node and Mongo app](https://github.com/openshift/origin/blob/master/examples/quickstarts/nodejs-mongodb.json)

- [Main samples repo](https://github.com/sclorg/nodejs-ex/blob/master/openshift/templates/nodejs.json) for basic Node all from Red Hat

- Back level, but explains concepts [article on template development](http://v1.uncontained.io/playbooks/fundamentals/template_development_guide.html)