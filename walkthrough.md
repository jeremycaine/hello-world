Docs
OpenShift 4.12 - https://access.redhat.com/documentation/en-us/openshift_container_platform/4.12
Building applications - https://access.redhat.com/documentation/en-us/openshift_container_platform/4.12/html/building_applications/index 

Section 3.3.1.1.Local
```
crc start

cd ~/code/github.com/jeremycaine/hello-world

```

Configuration > Image > YAML
add
```
...
spec:
  additionalTrustedCA:
    name: registry-certs
  allowedRegistriesForImport:
    - domainName: quay.io
      insecure: false
  registrySources:
    allowedRegistries:
      - quay.io
      - 'image-registry.openshift-image-registry.svc:5000'
...
```




# steps
https://kevinboone.me/podman_deploy.html?i=1

## node app
hello-word
git clone
run dev

## openshift local install
install crc
crc setup
crc start
podman -v ... error
eval $(crc oc-env)

## s2i from gh
test with build from gh
? does that need a change to registry etc

## podman build image
podman build ...
podman build -t hello-world:arm64 .

errors 
gvproxy

podman build
machine start
? do crc setup do podman init

## image into local registry
push

oc login -u developer ..
podman login -u kubeadmin -p $(oc whoami -t) default-route-openshift-image-registry.apps-crc.testing --tls-verify=false

oc new-project hello2
podman push hello:1 default-route-openshift-image-registry.apps-crc.testing/hello/hello:1 --tls-verify=false
oc get is

> allows the imagestream to be the source of images without having to provide the full URL to the internal registry.
oc set image-lookup hello-world

oc new-app --image-stream=hello-world

oc expose service/hello-world
oc status
curl http://hello-world-hello.apps-crc.testing/

oc expose service/hello-world
oc status
