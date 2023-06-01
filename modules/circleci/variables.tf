variable "provider_url" {
  type    = string
  default = "https://oidc.circleci.com/org"
}

variable "org_id" {
  type = string
}

variable "ssl_thumbprints" {
  type = list(any)
}

variable "environment" {
  type = string
}

variable "projects" {
  type = list(any)
}
