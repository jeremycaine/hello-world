# 6. Using Templates
A simple way to get started with an all encompassing build and deployment for local development is using OpenShift Template. Other ways of building and deploying applications include using CI/CD pipeline technology e.g. Argo, Jenkins, Ansible etc.

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

| Previous        | Next          |
| ------------- | -------------|
|[5. Configure Pod Security](5-configure-pod-security.md) | [Back to README](../README.md)|
