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
    "app/bp/frontend",
    "app/rpc/backend",
    "bb/im/sandbox-x-road/central-server",
    "bb/im/sandbox-x-road/security-server",
    "bb/payments/adapter",
    "bb/payments/emulator",
    "bb/digital-registries/emulator"
  ]
}
