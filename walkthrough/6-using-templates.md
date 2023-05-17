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

Next, as developer user create a new project and trigger the build and deployment using the template which requires the parameter PROJECT (namespace) to be specified:
```
oc new-project hello-6-2
oc new-app -f openshift/hello-world-template.yaml -p PROJECT=hello-6-2
oc new-app -f openshift/template2.yaml -p PROJECT=hello-6-2
```




| Previous        | Next          |
| ------------- | -------------|
|[5. Configure Pod Security](5-configure-pod-security.md) | [Back to README](../README.md)|
