# Modules

Contains reusable Terraform configurations for setting up various components of the infrastructure.

## [EKS](../modules/eks)

Defines a Sandbox Kubernetes cluster leveraging [EKS](https://aws.amazon.com/eks/).

## [ECR](../modules/ecr)

Defines a container registry using [ECR](https://aws.amazon.com/ecr/) to store container images and Helm charts.

**Registry naming pattern**

- Building blocks: bb/{block-name}/{building-block-implementation}/{dev/prod/etc}/{component-name}
- Applications: app/{use-case}/{dev/prod/etc}/{component-name}

## [Kubernetes](../modules/kube)

Contains additional configuration for the Kubernetes cluster. Currently empty.

## [CircleCI](../modules/circleci)

Contains [CircleCI](https://circleci.com/) OIDC authentication configuration for deployment to a Sandbox Kubernetes cluster. 

1. In the `live/<env>/env.hcl`, edit the values of the variable `project` under the CICD section. Provide an identifying name for the project and the project ID from CircleCI (found in project settings).
2. Navigate to `live/<env>/circleci` and run `terragrunt apply`.
3. As an output, you will receive roles for each separate CircleCI project. Use that role for the corresponding project for deployment.

### Environments

- Development: dev
- Production: prod
- Quality assurance: qa

