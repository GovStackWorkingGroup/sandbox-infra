#Tools
Just some little scripts to help out in stuff

##ssl_thumbprint.sh
Authorization of circleCI is done via oidc and setting that up we need ssl thumbprint of their certification. Instructions to calculate that is found at https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html

This script basicly just implements that 

###Usage
```
> ./ssl_thumbprint.sh https://oidc.circleci.com/org/<circleci org id>
```
the org id can be found from the circlci organization settings