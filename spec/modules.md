# Modules

## EKS 
Currently contains terraform files for creating new EKS cluster and setting up the VPC


## Elastic Container Registry

Sandbox uses a private container registry [AWS ECR](https://aws.amazon.com/ecr/) for storing container images ~~and Helm chars for deployment to the Sandbox~~.
Repositories for different images should follow a namespaced naming convention:  namespace/image-name, where

* namespace is a category for the images, e.g. a building block name (im-bb)
* image name is a descriptive name for the image (x-road-security-server)
* In addition, tags can be used to distinguish different versions and variants of the image (latest, 7.2-slim)


### Content

* [open-IMIS](https://github.com/GovStackWorkingGroup/sandbox-open-imis)
* [payment](https://github.com/GovStackWorkingGroup/sandbox-ph-ee)
* [information-mediator](https://github.com/GovStackWorkingGroup/sandbox-information-mediator)

## Kubernetes
Contains configuration for the kubernetes

## CircleCI
AWS authorization part. 