include "root" {
  path = find_in_parent_folders()
}

include "commons" {
    path = "${dirname(find_in_parent_folders())}/common/magic.hcl"
    expose = true
}

#environment specific inputs 

inputs = {
  ses_from_address = "akseli.karvinen@gofore.com"
}