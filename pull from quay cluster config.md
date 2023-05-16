Docs
OpenShift 4.12 - https://access.redhat.com/documentation/en-us/openshift_container_platform/4.12
Building applications - https://access.redhat.com/documentation/en-us/openshift_container_platform/4.12/html/building_applications/index 

Section 3.3.1.1.Local
```
crc start

cd ~/code/github.com/jeremycaine/hello-world

```

Configuration > Image > YAML
add
```
...
spec:
  additionalTrustedCA:
    name: registry-certs
  allowedRegistriesForImport:
    - domainName: quay.io
      insecure: false
  registrySources:
    allowedRegistries:
      - quay.io
      - 'image-registry.openshift-image-registry.svc:5000'
...
```




# steps
https://kevinboone.me/podman_deploy.html?i=1
