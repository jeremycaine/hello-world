## 3. OpenShift Local
Red Hat OpenShift Local was previously known as Code Ready Containers, and its command line functions are `crc`. 

### 3.1 Installation
Go to the [OpenShift Local site](https://developers.redhat.com/products/openshift-local/overview) and click through to "Install OpenShift of your laptop" (via your Red Hat account login). Also, the original [CRC Site](https://crc.dev) redirects there. My installation is onto a Macbook Pro M1 (download the MacOS `aarch64` installer package).

On MacOS use the installer package to install OpenShift Local. At that stage:
```
crc version

    CRC version: 2.17.0+44e15711
    OpenShift version: 4.12.9
    Podman version: 4.4.1
```

Next,
```
crc setup
```
On Mac this process will download a native macOS hypervisor for the virtual machine that OpenShift will run in. At this point the OpenShift command line `oc` and Podman are not configured.

Install and create an OpenShift cluster to run on your local machine. 
```
crc start
```
This creates a VM for OpenShift to run and completes the setup and configuration. Assuming your `pull-secret` file is in the same directory from where you ran `crc start` that part of the setup will be automatic. If not, you need to paste in the file contents when asked; this is a one-time task.

The cluster is now up and running
```
Started the OpenShift cluster.

The server is accessible via web console at:
  https://console-openshift-console.apps-crc.testing

Log in as administrator:
  Username: kubeadmin
  Password: kEg2Y-Nbeah-44LyK-Bp8be

Log in as user:
  Username: developer
  Password: developer

Use the 'oc' command line interface:
  $ eval $(crc oc-env)
  $ oc login -u developer https://api.crc.testing:6443
```
Execute 
```
eval $(crc oc-env)
```
Then `oc` and `podman` are setup. In the `~/.crc/bin` a directory `oc` is created with symbolic links to the executables, and `~/.crc/bin` is added to the PATH.

### 3.1 Container Build and Runtime Options
Now we have options for either Podman VMs created and started with `podman machine ...` or the OpenShift Local container runtime `crc`. 

To build a container image we can use Podman or Openshift. Both internally use `buildah` functions ([blog](https://podman.io/blogs/2018/10/31/podman-buildah-relationship.html)) to build OCI (Open Container Initative) images.

Then to run the application in the container image we execute in either the Podman VM or CRC. Let's assume we start both CRC (`crc start`) and the default machine in Podman (`podman machine start`), and assuming CRC is the default connection.
```
$ podman system connection list
Name                         URI                                                         Identity                                        Default
crc                          ssh://core@127.0.0.1:2222/run/user/1000/podman/podman.sock  /Users/jeremycaine/.crc/machines/crc/id_ecdsa   true
crc-root                     ssh://core@127.0.0.1:2222/run/podman/podman.sock            /Users/jeremycaine/.crc/machines/crc/id_ecdsa   false
podman-machine-default       ssh://core@localhost:49710/run/user/501/podman/podman.sock  /Users/jeremycaine/.ssh/podman-machine-default  false
podman-machine-default-root  ssh://root@localhost:49710/run/podman/podman.sock           /Users/jeremycaine/.ssh/podman-machine-default  false

# this is requesting list of images from the CRC image repository
$ podman images
REPOSITORY                                         TAG         IMAGE ID      CREATED       SIZE
localhost/hello-world                              step4       5d81c7c4cad4  13 hours ago  238 MB
localhost/hello-world                              step3       13b1ac917e6d  23 hours ago  1 GB
docker.io/library/node                             latest      306afa6471e5  7 days ago    975 MB
registry.access.redhat.com/ubi9/nodejs-16          latest      078c8f08f053  3 weeks ago   653 MB
registry.access.redhat.com/ubi9/nodejs-16-minimal  latest      9477cf32a6e9  3 weeks ago   210 MB

# but if we add the connection explicit to the Podman VM we get a different list
$ podman images
podman -c podman-machine-default images
REPOSITORY              TAG         IMAGE ID      CREATED       SIZE
localhost/hello-world   simple      c2de2f5d8914  15 hours ago  1 GB
docker.io/library/node  latest      306afa6471e5  7 days ago    975 MB

$ podman -c podman-machine-default run -dt -p 3001:3000 hello-world:simple
$ podman -c podman-machine-default logs -f 6512980de40b
$ podman -c podman-machine-default ps
$ podman -c podman-machine-default stop 6512980de40b
```
| Previous        | Next          |
| ------------- | -------------|
|[2. Local Podman Build and Run](2-local-podman-build-and-run.md) | [4. Local Podman Build and Run](4-deploy-local-image-to-openshift.md)|
