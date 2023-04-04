# steps

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
podman login -u developer -p $(oc whoami -t) default-route-openshift-image-registry.apps-crc.testing --tls-verify=false

oc new-project hello
podman push hello-world:arm64 default-route-openshift-image-registry.apps-crc.testing/hello/hello-world --tls-verify=false
oc get is

> allows the imagestream to be the source of images without having to provide the full URL to the internal registry.
oc set image-lookup hello-world

oc new-app --image-stream=hello-world
oc expose service/hello-world
oc status
