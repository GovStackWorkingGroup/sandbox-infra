# Sandbox Infrastructure

Contains infrastructure as terraform for the sandbox instances. Used by terragrunt.

## Structure
+ **live** - Contains terragrunt files for managing different environments. Divided by environment.
+ **modules** - Contains modules for infra written in terraform

## Current modules
+ **eks** - Currently contains terraform files for creating new EKS cluster and setting up the VPC
### Temporarily here from portal
+ **magiclink** - Contains cognito, some lambdas for creating the magic link and lambda and API for signIn for frontend to connect
+ **cognitolambda** - Submodule for magiclink, creates and deploys the lambda and appropriate resources they need

