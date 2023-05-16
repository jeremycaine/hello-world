# Hello World on OpenShift
Application container images built and deployed using OpenShift practices are fully Kubernetes compliant and can be deployed to any k8s cluster. This walkthrough demonstrates some of those foundational practices that result in secure and well managed deployments fit for operating in an enterprise environment.

6. add security, deploy without template
7. wrapping all together into template
8. push to quay registry
9. deploy to cloud hosted openshift cluster
10. deploy quay image to local kind/minikube

The main branch of the code is for the final complete configuration we want to achieve in OpenShift.







## 5. OpenShift Container security
change dockerfile

```
cp ./src/Dockerfile.openshift ./Dockerfile
podman build -t hello-world:step4 .
podman images
oc new-project hello-step4
podman push hello-world:step4 default-route-openshift-image-registry.apps-crc.testing/hello-step4/hello-world:step4 --tls-verify=false
oc get is
# image-stream = {project}/{name of image stream}:{tag given when push}
oc new-app --image-stream="hello-step4/hello-world:step4"
oc logs -f pod/hello-world-7b9b774f7b-dxpxw
```
Output
```
> hello-world@1.0.0 start
> node server.js

Server release 1 is running on http://localhost:3000
```
Now, container is running
```
oc status
curl http://hello-world-hello-step4.apps-crc.testing
```
Output
```
Hello World ! (release 1)
```
**** DO crc stop and see error message
**** DO AGAIN BUT WITH GRACEFULE CODE

```
crc stop
INFO Stopping kubelet and all containers...
ERRO Failed to stop all containers: ssh command error:
command : sudo -- sh -c 'crictl stop $(crictl ps -q)'
err     : Process exited with status 1
 - E0427 21:33:12.013733  109038 remote_runtime.go:505] "StopContainer from runtime service failed" err=<
	rpc error: code = Unknown desc = failed to update container status 73fe58d132ea7901df25d2be25b5a47d2a3185c72b97fc2e0dcd18686acc17dd: `/usr/bin/runc --root /run/runc --systemd-cgroup kill -a 73fe58d132ea7901df25d2be25b5a47d2a3185c72b97fc2e0dcd18686acc17dd 9` failed: time="2023-04-27T21:33:12Z" level=error msg="lstat /sys/fs/cgroup/devices/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-poda85e42e7_e8b5_4228_a38c_d9a8da7d98db.slice/crio-73fe58d132ea7901df25d2be25b5a47d2a3185c72b97fc2e0dcd18686acc17dd.scope: no such file or directory"
	 : exit status 1
 > containerID="73fe58d132ea7901df25d2be25b5a47d2a3185c72b97fc2e0dcd18686acc17dd"
time="2023-04-27T21:33:12Z" level=fatal msg="stopping the container \"73fe58d132ea7901df25d2be25b5a47d2a3185c72b97fc2e0dcd18686acc17dd\": rpc error: code = Unknown desc = failed to update container status 73fe58d132ea7901df25d2be25b5a47d2a3185c72b97fc2e0dcd18686acc17dd: `/usr/bin/runc --root /run/runc --systemd-cgroup kill -a 73fe58d132ea7901df25d2be25b5a47d2a3185c72b97fc2e0dcd18686acc17dd 9` failed: time=\"2023-04-27T21:33:12Z\" level=error msg=\"lstat /sys/fs/cgroup/devices/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-poda85e42e7_e8b5_4228_a38c_d9a8da7d98db.slice/crio-73fe58d132ea7901df25d2be25b5a47d2a3185c72b97fc2e0dcd18686acc17dd.scope: no such file or directory\"\n : exit status 1"
WARN Failed to stop all OpenShift containers.
Shutting down VM...
INFO Updating kernel args...
INFO Stopping the instance, this may take a few minutes...
Stopped the instance
```
#
#
## 2. Create the Deployment
The simple `hello-world` app in [repo](https://github.com/jeremycaine/hello-world) is a web app lisenting on port 3000 

Source code set release = 1
```
# Create a new project
git push ...
oc new-project hello

oc new-app .
oc expose service/hello-world
oc status
curl http://hello-world-hello.apps-crc.testing
> Hello World ! (release 1)
```

Now update the code for release 2 with the signal handling and graceful shutdown
```
git push ....
oc start-build hello-word
curl http://hello-world-hello.apps-crc.testing
> Hello World ! (release 2)

```
tail the logs
```
oc logs -f deployment/hello-world
...
> hello-world@1.0.0 start
> node server.js

Server release 2 is running on http://localhost:3000
called hello - release 2
```

now stop the deployment - console Deployments > scale pod to 0
```
SIGTERM signal received
HTTP server closed
hello-world app release 2 shutting down
npm timing command:run Completed in 485053ms
npm timing npm Completed in 485114ms
npm info ok
```


# Templates

oc get -o yaml all > hello.yaml








