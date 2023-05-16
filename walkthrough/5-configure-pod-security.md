# 5. Configure Pod Security
By design and by default the OpenShift implementation of Kubernetes restricts the privileges an application might expect it has e.g. access the file system. Security context constraints (SCC) are OpenShift resources that restricts a pod to use a group of resources. An introduction and tutorial to understand SCC is [here](https://developer.ibm.com/learningpaths/secure-context-constraints-openshift/scc-tutorial/).

Even with the security minded Dockerfile the `oc new-app` deployment of the application triggers this Warning
```
Warning: would violate PodSecurity "restricted:v1.24": allowPrivilegeEscalation != false (container "hello-world" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "hello-world" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "hello-world" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "hello-world" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
```

We are going to setup the controlled environment under which the application developer can deploy an application.

## 5.1 Cluster Level Configuration
The cluster administrator creates SCC, service account and Role Based Access Control definitions in the project namespace.

The developer is going to be allowed to create a deployment with a security context that has the allowed priviledges.

As `kubeadmin` create the SCC for the developer user named `scc-developer`
```
oc login -u kubeadmin -p ...

# create project (or let developer user create it) 
oc new-project hello-5-2

# ensure kubeadmin is in the correct project
oc project hello-5-2

# create a SecurityContextConstraint
oc create -f openshift/developer-scc.yaml
```
  
Next, create a service account that the developer will be part of
```
# create a service account
oc create sa developer-sa
```
create a role to use the SCC and bind that role to the service account
```
# apply RBAC
oc create -f openshift/developer-rbac.yaml
```

## 5.2 Developer Deplyment
Do the build.
```
cp ./src/server-v2.js ./server.js
cp ./src/Dockerfile.openshift ./Dockerfile
podman build -t hello-5-2:openshift .
podman images
```

Login as developer, set the project project, push the image into the project and return the image stream
```
oc login -u developer ...

# if required
oc project hello-5-2

podman login -u kubeadmin -p $(oc whoami -t) default-route-openshift-image-registry.apps-crc.testing --tls-verify=false
podman push hello-5-2:openshift default-route-openshift-image-registry.apps-crc.testing/hello-5-2/hello-5-2:openshift --tls-verify=false
```

The image is now in the internal OpenShift Local registry and instead of using `oc new-app` we can create a Service resource and Deployment from that image. This time the security context is set.
```
oc create -f openshift/developer-deploy-sc-sa.yaml
oc expose service/hello-5-2
```

As describe in [SCC tutorial](https://developer.ibm.com/learningpaths/secure-context-constraints-openshift/scc-tutorial/) if your cluster is OpenShift v4.11 or later, you will get a warning message from Pod Security Admission. However, the deployment will be created and work properly.

Call `oc status` 
```
In project hello-5-2 on server https://api.crc.testing:6443

http://hello-5-2-hello-5-2.apps-crc.testing to pod port 3000-tcp (svc/hello-5-2)
  deployment/hello-5-2 deploys image-registry.openshift-image-registry.svc:5000/hello-5-2/hello-5-2:openshift
    deployment #1 running for about a minute - 1 pod


1 info identified, use 'oc status --suggest' to see details.
```
and curl the URL returned e.g. `http://hello-5-2-hello-5-2.apps-crc.testing` to get the Hello World message.

If you now shell into your pod, as per the tutorial then you can see the pod is running under the defined secrutiy context.
```
sh-4.4$ whoami
1234 
sh-4.4$ id
wid=1234(1234) gid=5678 groups=5678,5555,5777,5888
```


| Previous        | Next          |
| ------------- | -------------|
|[4. Local Podman Build and Run](4-deploy-local-image-to-openshift.md) | [6. Using Templates](6-using-templates.md)|




