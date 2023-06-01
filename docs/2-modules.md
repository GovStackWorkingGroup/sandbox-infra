# Modules

## EKS 
[AWS Elastic Kubernetes Service](https://aws.amazon.com/eks/) contains terraform files
for creating kubernetes cluster and setting up the VPC.


## Elastic Container Registry

Sandbox uses a private container registry [AWS ECR](https://aws.amazon.com/ecr/) for storing container images.

### Naming convention
Repositories for different images should follow a namespace naming convention:  namespace/image-name, where

* namespace is a category for the images, e.g. a building block name (im-bb)
* image name is a descriptive name for the image (x-road-security-server)
* In addition, tags can be used to distinguish different versions and variants of the image (latest, 7.2-slim)

> **Note**
> ECR may contain BBs Helm charts.

### ECR contain next groups of images

* [open-IMIS](https://github.com/GovStackWorkingGroup/sandbox-open-imis)
* [payment](https://github.com/GovStackWorkingGroup/sandbox-ph-ee)
* [information-mediator](https://github.com/GovStackWorkingGroup/sandbox-information-mediator)
* [Mock-SRIS](https://github.com/GovStackWorkingGroup/sandbox-portal-backend)

## Kubernetes
Contains configuration for the kubernetes cluster.

### Environments

* Development - dev
* Production - prod
* Quality assurance - qa

## CircleCI

Contains [CircleCI](https://circleci.com/) authorization configuration for kubernetes cluster.