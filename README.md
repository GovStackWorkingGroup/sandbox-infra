# Sandbox Infrastructure

Contains infrastructure as terraform for the sandbox instances. Used by terragrunt.

## Structure
+ **live** - Contains terragrunt files for managing different environments. Divided by environment.
+ **modules** - Contains modules for infra written in terraform

## Usage

### Writing new module

1. Make a new folder to `modules/`
2. Write your code. Use variables, they are treated as inputs.

### Terragrunt
1. For the corresponding environment(dev, qa, prod) create a folder for your module and create `terragrunt.hcl` for that. 
  - This is where the input values are the same as variables in the terraform module
  - You can look for other modules as an example for it.
2. Navigate to `live/common` and create `your_module.hcl` for settings that apply all environments.
  - As before, others can be used as example
3. `live/<environment>/env.hcl` contains variables for environment specific variables. It is good place for i.e. version numbers

### Deployment
1. Navigate to `live/<env>/<your module>`
2. Validate your configuration with `terragrunt validate`. Fix what is needed
3. Say `terragrunt plan` to see what your changes will create. Check that it looks correct
4. Lastly, if everything is fine, apply your changes with `terragrunt apply`. It will run plan again and asks if you want to apply it
5. Check that your configuration works
