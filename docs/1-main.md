# GovStack Sandbox Infrastructure Documentation

This repository is part of the [GovStack sandbox](https://github.com/GovStackWorkingGroup/sandbox).

The GovStack Sandbox aims to be an isolated, safe environment simulating a small governmental e-service system (reference implementation of the GovStack). It is a demonstration environment to learn and a technical environment to test and develop digital government services based on the GovStack approach.

The Sandbox Infrastructure provides the lowest layer of the Sandbox — a Kubernetes environment for
deploying and running compatible [building block](https://govstack.gitbook.io/specification/) implementations.

## Structure

+ **live** - Contains terragrunt files for managing different environments. Divided by environment.
+ **[modules](./2-modules.md)** - Contains modules for infra written in Terraform

## How to run

### Requirements

* Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* Install [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
* Install [AWS Command line tool](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

1. Checkout the repostory
2. First navigate to `live/<env>` Where <env> is the environment you want to deploy
3. Open up `live/<env>/env.hcl` and edit your project values there.
  * Most importat ones at this point are aws account id, product name and enivronment name
  * All the environment specific values are configured here
4. Check that you have configured your aws credentials and they are working
5. You can now enter `live/<env>/<module>` and run the following
  * `terragrunt init`
  * `terragrunt validate`
  * `terragrunt plan`
  * if everything looks valid, run `terragrunt apply` to deploy the infrastructure

  module Kube is dependent of EKS, so be sure to run EKS first

### CircleCI

The module CircleCI creates oidc authentication for the aws to enable deployment from circleCI to the Kubernetes. It limits the access to certain projects
1. In the `live/<env>/env.hcl` edit the values of variable `project` Under CICD section. it takes an identifing name of the project and the project id from the circleCI(found in project settings)
2. Navigate `live/<env>/circleci` and run the terragrunt like in above.
3. As an output it gives you roles for each separate CircleCI project. Now use that role for the corresponding project to deployment.
