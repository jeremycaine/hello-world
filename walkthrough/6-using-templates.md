# 6. Using Templates
OpenShift Template are a starting point for creating all encompassing build and deployment of OpenShift applications.

A simple way to get started with an all encompassing build and deployment for local development is using OpenShift Templates. Other ways of building and deploying applications include using CI/CD pipeline technology e.g. Argo, Jenkins, Ansible etc.

## 6.1. Push to Github
The template will build from the Github repository, therefore we need to commit all the files to a repo.

Remember we had these two file replacements:
```
cp ./src/server-v2.js ./server.js
cp ./src/Dockerfile.openshift ./Dockerfile
```

As long as anything hasn't changed here then you have the correct `server.js` and `Dockerfile`.

Push your local repo to remote:
```
git add .
git commit -m "ready for template build"
git push
```

## 6.2. Deploy from Template
An OpenShift Template is a set of directives to build various OpenShift and Kubernetes resources.

The example template file is [openshift/hello-world-template.yaml](../openshift/hello-world-template.yaml).

First, setup project as the developer.
```
oc login -u developer -p ...
oc new-project hello-t
```

Next add security context to the project. As `kubeadmin` create the SCC for the developer user named `scc-developer`. 
```
oc login -u kubeadmin -p ...

# ensure kubeadmin is in the correct project
oc project hello-t

# If you create the SCC in the previous step you will get a message it already exists
# create a SecurityContextConstraint
oc create -f openshift/developer-scc.yaml

# create a service account in the Project Namespace that the developer owns
oc create sa developer-sa

# create a role to use the SCC and bind that role to the service account
# apply RBAC
oc create -f openshift/developer-rbac.yaml
oc logout
```

Next, as developer user trigger the build and deployment using the template which requires the parameter PROJECT (namespace) to be specified:
```
oc login -u developer -p ...
oc new-app -f openshift/hello-world-template.yaml -p PROJECT=hello-t
```

## 6.3 Understanding the Template Build and Deploy
Creating a new application from template shows these messages:
```
--> Deploying template "hello-t/hello-world-template" for "openshift/hello-world-template.yaml" to project hello-t

     Node.js
     ---------
     Simple Hello World app in NodeJS

     * With parameters:
        * Name=hello-world
        * Project=hello-t
        * Service Account Name=developer-sa
        * Memory Limit=256Mi
        * Git Repository URL=https://github.com/jeremycaine/hello-world
        * Git Reference=main
        * Application Hostname=
        * GitHub Webhook Secret=S1HLODYUX0b86WTtIllGJIN8B1cT34kDO2wpBroG # generated
        * Generic Webhook Secret=MjsK1QyfAwqEiJrnNLI1dJ7VhpfHRwnKrh5iXlby # generated
        * Server Listen Port=3000

--> Creating resources ...
    service "hello-world-service" created
    route.route.openshift.io "hello-world-route" created
    imagestream.image.openshift.io "hello-world" created
    imagestream.image.openshift.io "nodejs-16-minimal" created
    buildconfig.build.openshift.io "hello-world-build" created
    deploymentconfig.apps.openshift.io "hello-world-deployment" created
--> Success
    Access your application via route 'hello-world-route-hello-t.apps-crc.testing'
    Build scheduled, use 'oc logs -f buildconfig/hello-world-build' to track its progress.
    Run 'oc status' to view your app.
```
After a few minutes the application is up and running, `oc status` gives
```
In project hello-t on server https://api.crc.testing:6443

http://hello-world-route-hello-t.apps-crc.testing (svc/hello-world-service)
  dc/hello-world-deployment deploys istag/hello-world:latest <-
    bc/hello-world-build docker builds https://github.com/jeremycaine/hello-world#main on istag/nodejs-16-minimal:latest
    deployment #1 deployed 3 minutes ago - 1 pod

View details with 'oc describe <resource>/<name>' or list resources with 'oc get all'.
```
Then you can access the application with `curl http://hello-world-route-hello-t.apps-crc.testing`

| Previous        | Next          |
| ------------- | -------------|
|[5. Configure Pod Security](5-configure-pod-security.md) | [7. Vanilla Kubernetes](7-vanilla-kubernetes.md)|
