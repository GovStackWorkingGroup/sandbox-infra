# GovStack Sandbox Infrastructure Documentation 

This repository is part of the [GovStack sandbox](https://github.com/GovStackWorkingGroup/sandbox).

## How to run

Contains infrastructure as terraform for the sandbox instances. Used by terragrunt.

## Structure
+ **live** - Contains terragrunt files for managing different environments. Divided by environment.
+ **[modules](./2-modules.md)** - Contains modules for infra written in terraform