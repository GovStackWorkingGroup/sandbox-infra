# Sandbox Infrastructure repository

This repository is a part of [GovStack Sandbox project](https://github.com/GovStackWorkingGroup/sandbox).

More information can be found in the [documentation](https://oleksii-1.gitbook.io/sandbox-infra/). 

## Specifics for AWS Terraform cluster destroy with enabled Karpenter - Tear Down & Clean-Up

{% hint style="info" %} Because Karpenter manages the state of node resources outside of Terraform, Karpenter created resources will need to be de-provisioned first before removing the remaining resources with Terraform. {% endhint %}

1. Remove the example deployment created above and any nodes created by Karpenter (in the example is tomcatinfra):

```shell 
kubectl delete deployment tomcatinfra
```

Wait for nodes to be removed by Karpenter or execute below command to force remove the nodes:

```shell 
kubectl delete node -l karpenter.sh/provisioner-name=default
```

2. Remove the resources created by Terraform

```shell 
terragrunt destroy
```

{% hint style="info" %} Example deployment: 

```shell 
kubectl create deployment tomcatinfra --image=saravak/tomcat8 --replicas=21
``` 
{% endhint %}