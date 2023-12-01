include "root" {
  path = find_in_parent_folders()
}

include "commons" {
    path = "${dirname(find_in_parent_folders())}/common/ecr.hcl"
    expose = true
}

#environment specific inputs 

inputs = {
  repositories = [
    "app/usct/backend",
    "app/usct/frontend",
    "bb/im/sandbox-x-road"
  ]
}