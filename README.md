# GovStack Sandbox Infrastructure

This repository is a part of the [GovStack Sandbox](https://govstack.gitbook.io/sandbox).

The GovStack Sandbox aims to be an isolated, safe environment simulating a small governmental e-service system (a reference implementation of the GovStack). It is a demonstration environment for learning and a technical environment for testing and developing digital government services based on the GovStack approach.

The Sandbox Infrastructure provides the lowest layer of the Sandbox — a Kubernetes environment for deploying and running compatible [building block](https://govstack.gitbook.io/specification/) implementations.

## Structure

- [live](live) - Contains Terragrunt files for managing different environments, divided by environment.
- [modules](modules) - Contains [modules](docs/modules.md) for infrastructure written in Terraform.

## Getting started

You need the following tools:

- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [AWS Command line tool](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)

Verify that you have AWS credentials properly configured.

1. Clone this repository.
2. Navigate to `live/<env>` where `<env>` is the environment you want to deploy.
3. Open up `live/<env>/env.hcl` to edit your project values.
   - The most important ones are AWS account ID, product name, and environment name.
   - All the environment-specific values are configured here.
4. You can now enter `live/<env>/<module>` and run the following:
   - `terragrunt init`
   - `terragrunt validate`
   - `terragrunt plan`

   If everything looks valid, run `terragrunt apply` to deploy the infrastructure.
   Note that module Kube is dependent on EKS, so be sure to run EKS first.

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