include "root" {
  path = find_in_parent_folders()
}

include "commons" {
    path = "${dirname(find_in_parent_folders())}/common/bb-payment.hcl"
    expose = true
}

#environment specific inputs 

inputs = {
  cluster_name = "sandbox"
}