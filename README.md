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
## Security
Withouth the next security set up you get the error message when `oc new-app`:
```
...
--> Creating resources ...
Warning: would violate PodSecurity "restricted:v1.24": allowPrivilegeEscalation != false (container "hello-world" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "hello-world" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "hello-world" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "hello-world" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
    deployment.apps "hello-world" created
...
```

as kubeadmin
```
# create a SecurityContextConstraints
oc create -f openshift/developer-scc.yaml

# create a service account
oc create sa developer-sa

# apply RBAC
oc create -f openshift/developer-rbac.yaml
```

as developer
```
oc new-project hello2
oc new-app --file=openshift/hello-world-template.yaml --param=NAME=hello --param=PROJECT=hello2
```

W0414 18:10:07.928204    3532 shim_kubectl.go:58] Using non-groupfied API resources is deprecated and will be removed in a future release, update apiVersion to "template.openshift.io/v1" for your resource
--> Deploying template "hello3/${NAME}" for "openshift/hello-world-template.yaml" to project hello3

     Node.js
     ---------
     Simple Hello World app in NodeJS

     The following service(s) have been created in your project: hello3.


     * With parameters:
        * Name=hello3
        * Memory Limit=256Mi
        * Git Repository URL=https://github.com/jeremycaine/hello-world.git
        * Git Reference=
        * Context Directory=
        * Application Hostname=
        * GitHub Webhook Secret=jIW1lrFutHWSOwhRirBEM3QxKakaLYEMwmXt7ClY # generated
        * Generic Webhook Secret=lGD80IRbtgqfy4vjuWPruEHJhgxS0IcmO4HyO5td # generated
        * Server Listen Port=3000

W0414 18:10:07.985680    3532 newapp.go:1335] Unable to check for circular build input: Unable to check for circular build input/outputs: imagestreams.image.openshift.io "nodejs-16-minimal" not found
--> Creating resources ...
    service "hello3" created
    route.route.openshift.io "hello3-route" created
    imagestream.image.openshift.io "hello3" created
    buildconfig.build.openshift.io "hello3" created
    deploymentconfig.apps.openshift.io "hello3" created
--> Success
    Access your application via route 'hello3-route-hello3.apps-crc.testing'
    Build scheduled, use 'oc logs -f buildconfig/hello3' to track its progress.
    Run 'oc status' to view your app.

# Templates

oc get -o yaml all > hello.yaml
