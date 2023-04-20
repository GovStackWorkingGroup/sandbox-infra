# Main

## How to run

Contains infrastructure as terraform for the sandbox instances. Used by terragrunt.

## Structure
+ **live** - Contains terragrunt files for managing different environments. Divided by environment.
+ **modules** - Contains modules for infra written in terraform

### Environments

* Development - dev
* Production - prod
* Quality assurance - qa