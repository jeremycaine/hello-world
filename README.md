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
Ensure podman is running, `init` not required once podman installed and VM created.
```
podman machine init
podman machine start
```

If you have not started the podman machine and try to do podman actions you get this error message:
```
Error: failed to connect: dial tcp [::1]:65202: connect: connection refused
```

## 3. Dockerfile
The Dockerfile uses best practices for designing a universal application image [link](https://developer.ibm.com/learningpaths/universal-application-image/). This builds efficient, high-quality images that run well in both Kubernetes and Red Hat OpenShift.

## 4. Build and Run Image Locally
Build and Run on a Macbook M1 - arm64 architecture. The podman build picks up on the compute it is running on, so no need to add an `--arch` flag for `arm64`
```
podman build -t hello-world:arm64 .
podman images
podman run --name hello -p 3001:3000 localhost/hello-world:arm64 &
```
This shows how the port the app listens on (3000) is mapped ot the port to serve the container on (3001). Access the app via `localhost:3001`

Cleanup actions
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

## 4. Push image into OpenShift
Log in to OpenShift as admin
```
eval $(crc oc-env)
```

Log podman into the OpenShift Local registry.
```
podman login -u kubeadmin -p $(oc whoami -t) default-route-openshift-image-registry.apps-crc.testing --tls-verify=false

oc login -u developer ..
oc new-project hello
podman push hello-world:arm64 default-route-openshift-image-registry.apps-crc.testing/hello/hello-world:latest --tls-verify=false
oc get is

# allows the imagestream to be the source of images without having to provide the full URL to the internal registry.
oc set image-lookup hello-world

oc new-app --image-stream=hello-world
```
with output
```
--> Found image 0527aae (7 minutes old) in image stream "hello/hello-world" under tag "latest" for "hello-world"

    Node.js 16 Micro
    ----------------
    Node.js 16 available as container is a base platform for running various Node.js 16 applications and frameworks. Node.js is a platform built on Chrome's JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.

    Tags: builder, nodejs, nodejs16


--> Creating resources ...
Warning: would violate PodSecurity "restricted:v1.24": allowPrivilegeEscalation != false (container "hello-world" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "hello-world" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "hello-world" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "hello-world" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
    deployment.apps "hello-world" created
    service "hello-world" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose service/hello-world'
    Run 'oc status' to view your app.
```

```
oc expose service/hello-world
oc status
curl http://hello-world-hello.apps-crc.testing/
```


## 4. Deploy in OPenshift

Log in to OpenShift on cloud and two deployment options
```
oc login --token...
oc new-project hello

# build from source
oc new-app https://github.com/jeremycaine/hello-world

# build from image
oc new-app --image=quay.io/jeremycaine/hello-world:amd64

oc expose service/hello-world

# get URL of deployment from
oc status
```

## x. Quay and Red Hat OpenShift IBM Cloud

### x.1 Build and Push to Quay Registry
Build to the amd64 architecture for deployment in the cloud.
```
podman build --arch=amd64 -t hello-world:amd64 .
podman images
podman login quay.io
podman push hello-world:amd64 quay.io/jeremycaine/hello-world:amd64
```

## References

https://developer.ibm.com/tutorials/running-x86-64-containers-mac-silicon-m1/ 

https://podman-desktop.io/docs/troubleshooting#unable-to-set-custom-binary-path-for-podman-on-macos 

https://developer.ibm.com/learningpaths/universal-application-image/design-universal-image/ 

