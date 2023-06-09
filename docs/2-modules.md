# Modules

## EKS 
[AWS Elastic Kubernetes Service](https://aws.amazon.com/eks/) contains terraform files
for creating kubernetes cluster and setting up the VPC.


## Elastic Container Registry

Sandbox uses a private container registry [AWS ECR](https://aws.amazon.com/ecr/) for storing container images.

### Naming pattern

BBs : bb/{block_name}/{building-block-implementation}/{dev/prod/etc}/{component-name}
APPs: app/{use-case}/{dev/prod/etc}/{component-name}

> **Note**
> ECR may contain BBs Helm charts.

### ECR contain next groups of images

* [open-IMIS](https://github.com/GovStackWorkingGroup/sandbox-open-imis)
* [payment](https://github.com/GovStackWorkingGroup/sandbox-ph-ee)
* [information-mediator](https://github.com/GovStackWorkingGroup/sandbox-information-mediator)
* [app/usct/backend](https://github.com/GovStackWorkingGroup/sandbox-portal-backend)
* [app/usct/ui](https://github.com/GovStackWorkingGroup/sandbox-playgroud)

## Kubernetes
Contains configuration for the kubernetes cluster.

### Environments

* Development - dev
* Production - prod
* Quality assurance - qa

## CircleCI

Contains [CircleCI](https://circleci.com/) authorization configuration for kubernetes cluster.