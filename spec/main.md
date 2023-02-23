# Main

## Databases

Amazon Relational Database Service  [RDS](https://aws.amazon.com/rds/) can be used as a starting point for [BBs](https://govstack.gitbook.io/specification/building-blocks/about-building-blocks) that expect to have database as dependency.

### Prerequisites

* [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)
* [helm chart](https://helm.sh/docs/topics/charts/)

More information you can find in a [related documentation](https://aws-controllers-k8s.github.io/community/docs/tutorials/rds-example/#install-the-ack-service-controller-for-rds).

## Container Registry

Sandbox uses a private container registry (AWS ECR) for storing container images and Helm chars for deployment to the Sandbox.  Repositories for different images should follow a namespaced naming convention:  namespace/image-name, where

* namespace is a category for the images, e.g. a building block name (im-bb)
* image name is a descriptive name for the image (x-road-security-server)
* In addition, tags can be used to distinguish different versions and variants of the image (latest, 7.2-slim)

For example. a full reference to an im-bb image:

`https://aws_account_id.dkr.ecr.eu-central-1.amazonaws.com/im-bb/x-road-security-server:7.2-slim`