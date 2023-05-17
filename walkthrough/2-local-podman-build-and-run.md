# 2. Local Podman Build and Run
The installation and configuration of `podman` and how to build and run a container image.

## 2.1 Podman Install
Install podman
```
brew install podman
where podman
# /opt/homebrew/bin/podman
```
Now start Podman
```
podman machine start
```
On Mac you will hit this networking issue:
```
Starting machine "podman-machine-default"
Error: unable to start host networking: "could not find \"gvproxy\" in one of [/Users/jeremycaine/.gvproxy].  To resolve this error, set the helper_binaries_dir key in the `[engine]` section of containers.conf to the directory containing your helper binaries."
```
Follow the instructions [here](https://podman-desktop.io/docs/troubleshooting#unable-to-set-custom-binary-path-for-podman-on-macos) to solve this networking issue. 

The steps you will go through:
- download the source and extract to a directory
- run `make` to build the helper functions
- copy the three executables (`gvproxy`, `qemu-wrapper`, and `vm`) to `~/.gvproxy` directory.
- update `~/.config/containers/containers.conf`: 
```
[containers]

[engine]
  helper_binaries_dir = ["/Users/jeremycaine/.gvproxy"]
  active_service = "crc"
  ...
```
Now we can start Podman
```
podman machine start
```
Output
```
Starting machine "podman-machine-default"
Waiting for VM ...
Mounting volume... /Users:/Users
Mounting volume... /private:/private
Mounting volume... /var/folders:/var/folders

This machine is currently configured in rootless mode. If your containers
require root permissions (e.g. ports < 1024), or if you run into compatibility
issues with non-podman clients, you can switch using the following command:

	podman machine set --rootful

API forwarding listening on: /var/run/docker.sock
Docker API clients default to this address. You do not need to set DOCKER_HOST.

Machine "podman-machine-default" started successfully
```
You can see the VM instances of container runtime engines with `podman system connection ls`. You see that `podman-machine-default` is the default one.
```
Name                         URI                                                         Identity                                        Default
podman-machine-default       ssh://core@localhost:49710/run/user/501/podman/podman.sock  /Users/jeremycaine/.ssh/podman-machine-default  true
podman-machine-default-root  ssh://root@localhost:49710/run/podman/podman.sock           /Users/jeremycaine/.ssh/podman-machine-default  false
```
Later when CRC is installed, another container runtime `crc` will be created - this is where the OpenShift cluster will run.

## 2.2 Podman Build
We are going to start with a pretty standard Dockerfile and show how that is treated in the OpenShift world. First we get that simple Dockerfile and build the image. 

Using the application source that handles signal interrupts. The image is created in the `podman-machine-default` repository.
```
cp ./src/server-v2.js ./server.js
cp ./src/Dockerfile.simple ./Dockerfile
podman build -t hello-world:simple .
podman images
```

## 2.3. Podman Run
Next we will run the Hello World program in a container (and at this point it will run in the `podman-machine-default` container runtime). The program listens on Linux port 3000 inside its container, and we map to 3001 port of macOS that our browser will connect to. 

The image executes in the `podman-machine-default` container runtime.
```
podman run -dt -p 3001:3000 hello-world:simple
podman ps
# returns container id e.g. b27df0794b3a
podman logs -t b27df0794b3a
```
Log will show
```
npm info using npm@9.6.4
npm info using node@v20.0.0

> hello-world@1.0.0 start
> node server.js

Build:
-version: v2
-description: Simple server; With Signal intercept

Process ID: 15
Server version is running on http://localhost:3000
```
Testing will return hello message
```
$ curl http://localhost:3001
Hello World ! (version v2)
```
and the logs at `podman logs -t b27df0794b3a` show the call to the server made.
```
...
2023-04-28T16:59:08+01:00 Server version is running on http://localhost:3000
2023-04-28T17:00:00+01:00 hello-world called
```

| Previous        | Next          |
| ------------- | -------------|
|[1. Hello World Application](1-hello-world-begin.md) | [3. OpenShift Local](3-openshift-local.md)|
