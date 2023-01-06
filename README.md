# Hello World
A simple Hello World! NodeJS app built for the OpenShift platform.

## 1. Local Development
```
git clone https://github.com/jeremycaine/hello-world
cd hello-world
npm install
npm run start
curl http://127.0.0.1:3000/
```

## 2. Local Podman
Build and Run
```
podman build -t hello-world .
podman images
podman run --name hello -p 3001:3000 localhost/hello-world
```
This shows how the port the app listens on (3000) is mapped ot the port to serve the container on (3001). Access the app via `localhost:3001`

Cleanup
```
# in case you need to re-run
podman rm hello

# stop containers
podman stop --all

# remove image for clean re-built
podman rmi hello-word
```

## 3. OpenShift Local 
Set up OpenShift Local (was CRC).

### 3.1 Deploy from Image
Log in to OpenShift as a developer
```
eval $(crc oc-env)
oc login -u developer https://api.crc.testing:6443
oc whoami
```

Log podman into the OpenShift Local registry.
```
podman login -u kubeadmin -p $(oc whoami -t) default-route-openshift-image-registry.apps-crc.testing --tls-verify=false
podman push hello-world default-route-openshift-image-registry.apps-crc.testing/hello-world --tls-verify=false
oc get is

# allows the imagestream to be the source of images without having to provide the full URL to the internal registry.
oc set image-lookup hello-world
oc run demo --image=hello-world 
```

Now as developer, deploy the image
```
oc login -u developer ...

```

### 3.2. Build and Deploy from Source


curl -kv https://default-route-openshift-image-registry.apps-crc.testing


## x. Push to Quay and Test in Public Cloud
Build to the amd64 architecture for deployment in the cloud.
```
podman build --arch=amd64 -t hello-world:amd64 .
podman images
podman login quay.io
podman push hello-world:amd64 quay.io/jeremycaine/hello-world:amd64
```

### x.1 Build from Source
Red Hat OpenShift on IBM Cloud
```
oc login --token...
oc new-project caine https://github.com/jeremycaine/hello-world
oc expose service/hello-world

# get URL of deployment from
oc status
```