# OpenShift build docs

```
oc new-project caine

# create a service account
oc create serviceaccount sa-caine

oc adm policy add-scc-to-user anyuid -z sa-caine
oc set serviceaccount deployment deployment-name sa-name

oc new-app . --name=css
oc expose service/css
oc status
```

Dockerfile

FROM base image
https://catalog.redhat.com/software/containers/rhel8/nodejs-16-minimal/615aefc7c739c0a4123a87e2 

e.g. 