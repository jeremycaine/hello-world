# 4. Deploy Local Image to OpenShift Local
Deployment and run of images in OpenShift Local and description of OpenShift optimised Dockerfile.

Start the OpenShift Cluster with `crc start` and confirm the Podman target with `podman system connnection list`.

Login to OpenShift Cluster e.g. as `developer` for OpenShift Local and setup a new project (namespace).
```
eval $(crc oc-env)
oc login -u developer https://api.crc.testing:6443
oc new-project hello-4-1
```

## 4.1 Push Local Image into OpenShift Local Registry
Build the image we want to push into OpenShift. This will be the v2 code that handles interrupts and the simple Dockerfile.

```
cp ./src/server-v2.js ./server.js
cp ./src/Dockerfile.simple ./Dockerfile
podman build -t hello-world:simple .
podman images
```
Next, we will put the image in OpenShift registry
```
# parameter passed to user has no effect here
podman login -u kubeadmin -p $(oc whoami -t) default-route-openshift-image-registry.apps-crc.testing --tls-verify=false

podman push hello-world:simple default-route-openshift-image-registry.apps-crc.testing/hello-4-1/hello-world:simple --tls-verify=false

oc get is
# returns {image-stream-name}
# deploy an application from the image stream composed of these parts: {project}/{image-stream-name}:{tag given when push}
oc new-app --image-stream="hello-4-1/hello-world:simple"
```
The deployment output will be
```

--> Found image b939d4c (About a minute old) in image stream "hello-4-1/hello-world" under tag "simple" for "hello-4-1/hello-world:simple"


--> Creating resources ...
Warning: would violate PodSecurity "restricted:v1.24": allowPrivilegeEscalation != false (container "hello-world" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "hello-world" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "hello-world" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "hello-world" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
    deployment.apps "hello-world" created
    service "hello-world" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose service/hello-world'
    Run 'oc status' to view your app.
```
You can already see that OpenShift is flagging a security violation from what it can see in the container image definition.

Next we expose the service which creates the URL (via `oc status`) from which you can do a test call.
```
oc expose service/hello-world
oc status
```

The application does not respond to `curl http://hello-world-hello-4-1.apps-crc.testing` (the URL given by `oc status`) because the container deployment is failing (CrashLooping). Checking the logs reveals there is an issue with security.
```
oc get all
# see pod/hello-world-... and it is CrashLooping
oc logs -f pod/hello-world-855d9798f9-9p6jz
```
The log shows the application errors.
```
npm info using npm@9.6.4
npm info using node@v20.0.0

> hello-world@1.0.0 start
> node server.js

Server release 1 is running on http://localhost:3000
npm ERR! code EACCES
npm ERR! syscall mkdir
npm ERR! path /.npm
npm ERR! errno -13
npm ERR!
npm ERR! Your cache folder contains root-owned files, due to a bug in
npm ERR! previous versions of npm which has since been addressed.
npm ERR!
npm ERR! To permanently fix this problem, please run:
npm ERR!   sudo chown -R 1000660000:0 "/.npm"

npm ERR! Log files were not written due to an error writing to the directory: /.npm/_logs
npm ERR! You can rerun the command with `--loglevel=verbose` to see the logs in your terminal
```
The security model of OpenShift does not - by default - allow applications to perform root actions. This is a key concept of OpenShift to implement guard rails for secure, enterprise ready container based application operations.

To tidy up you can delete the project
```
oc delete project hello-4-1
```

## 4.2 Building to Run in OpenShift
In order to deploy and run a container with the correct priviliges we need to follow some specific practices.

This time we will build the image we want to push into OpenShift using the v2 code again, but this time with an OpenShift Dockerfile. As we will show later the image produced is not proprietary to OpenShift, it is a Kubernetes standard image.

An in depth exploration of this best practice Dockerfile for OpenShift is [here](https://developer.ibm.com/learningpaths/universal-application-image/design-universal-image/)

The Dockerfile looks like this
```
# Two stage build

# Stage 1: builder image
FROM registry.access.redhat.com/ubi9/nodejs-16 AS builder

## Add application sources
ADD . $HOME

## Install dependencies based on the preferred package manager
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Stage 2:  deployment image
## 1. Unversial Base Image (UBI)
FROM registry.access.redhat.com/ubi9/nodejs-16-minimal

## 2. Non-root, arbitrary user IDs
USER 1001

## 3. Image identification
LABEL name="jeremycaine/hello-word" \
      vendor="Acme, Inc." \
      version="1.2.3" \
      release="45" \
      summary="hello world web application" \
      description="This application says hello world."

USER root

## 4. Image license
## Red Hat requires that the image store the license file(s) in the /licenses directory. 
## Store the license in the image to self-document
COPY ./licenses /licenses

## 5. Latest security updates
## RUN dnf -y update-minimal --security --sec-severity=Important --sec-severity=Critical && \
##    dnf clean all

## on minimal UBI images use microdnf
RUN microdnf -y upgrade && \
    microdnf clean all

## 6. Group ownership and file permission
RUN chgrp -R 0 $HOME && \
    chmod -R g=u $HOME

USER 1001
RUN chown -R 1001:0 $HOME

## 7. Application source
## Copy the application source and build artifacts from the builder image to this one
COPY --from=builder $HOME $HOME

## Set environment environment variables and expose port
ENV NODE_ENV production
ENV PORT 3000
EXPOSE 3000

## Run script uses standard ways to run the application
CMD npm run -d start
```
Do the build.
```
cp ./src/server-v2.js ./server.js
cp ./src/Dockerfile.openshift ./Dockerfile
podman build -t hello-4-2:openshift .
podman images
```

Create a new project and push that image into OpenShift
```
oc new-project hello-4-2

podman login -u kubeadmin -p $(oc whoami -t) default-route-openshift-image-registry.apps-crc.testing --tls-verify=false
podman push hello-4-2:openshift default-route-openshift-image-registry.apps-crc.testing/hello-4-2/hello-4-2:openshift --tls-verify=false

oc get is
# returns {image-stream-name}
# deploy an application from the image stream composed of these parts: {project}/{image-stream-name}:{tag given when push}
oc new-app --image-stream="hello-4-2/hello-4-2:openshift"
```
The deployment now looks like this and note you still see a Warning
```

--> Found image 368d582 (2 minutes old) in image stream "hello-4-2/hello-world" under tag "openshift" for "hello-4-2/hello-world:openshift"

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

Expose the application with `oc expose service/hello-world`.

Now `oc get all` will show all is ok with the pod and a test e.g. `curl http://hello-4-2-hello-4-2.apps-crc.testing` returns the exepcted Hello World message.


| Previous        | Next          |
| ------------- | -------------|
|[3. OpenShift Local](3-openshift-local.md) | [5. Configure Pod Security](5-configure-pod-security.md)|
