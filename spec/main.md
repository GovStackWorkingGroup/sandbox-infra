# Main

## Databases

Amazon Relational Database Service  [RDS](https://aws.amazon.com/rds/) can be used as a starting point for [BBs](https://govstack.gitbook.io/specification/building-blocks/about-building-blocks) that expect to have database as dependency.

### Prerequisites

* [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)
* [helm chart](https://helm.sh/docs/topics/charts/)

More information you can find in a [related documentation](https://aws-controllers-k8s.github.io/community/docs/tutorials/rds-example/#install-the-ack-service-controller-for-rds).

## Docker container registry

Each component of BB has dedicated [ECR](https://aws.amazon.com/ecr/) repository.

[For example](https://github.com/GovStackWorkingGroup/sandbox-infra/blob/main/modules/ecr/main.tf).