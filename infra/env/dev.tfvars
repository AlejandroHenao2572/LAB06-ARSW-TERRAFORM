prefix              = "lab6"
location            = "centralus"
vm_count            = 2
admin_username      = "student"
ssh_public_key      = "~/.ssh/id_ed25519.pub"
allow_ssh_from_cidr = "186.28.26.89/32"
tags = {
  owner   = "AlejandroHenao2572"
  course  = "ARSW"
  env     = "dev"
  expires = "2026-12-31"
}