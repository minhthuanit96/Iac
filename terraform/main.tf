provider "vsphere" {
  user           = "Administrator@ibasic.local"
  password       = "Minhthu@n1996"
  vsphere_server = "192.168.1.200"
  allow_unverified_ssl = true
}

# Deploy linux VMs
module "linuxvm" {
  source  = "Terraform-VMWare-Modules/vm/vsphere"
  version = "3.8.0"
  vmtemp    = "ubuntu-template"
  instances = 1
  vmname    = "example-server-linux"
  vmrp      = "Resource_Pool"
  ram_size  = "2048"
  domain    = ""
  network = {
    "VM Network" = [""] # To use DHCP create Empty list ["",""]; You can also use a CIDR annotation;
  }
  vmgateway = "192.168.1.1"
  dc        = "localhost.localdomain"
  datastore = "Store"
}

output "vm_ip" {
  value = module.linuxvm.ip
}

# resource "null_resource" "ssh_key_setup" {
#   depends_on = [module.linuxvm]
#   provisioner "local-exec" {
#     command = <<-EOF
#       user="it"
#       host="${module.linuxvm.ip[0]}"
#       password="it"
#       public_key="~/.ssh/my_ssh_key.pub"
#       echo "Generating SSH keys..."
#       if [ -f ~/.ssh/my_ssh_key ]; then
#         rm ~/.ssh/my_ssh_key
#       fi
#       ssh-keygen -t rsa -b 2048 -f ~/.ssh/my_ssh_key -N ""
#       # Usee sshpass to copy ssh-copy-id to server
#       sshpass -p "$password" ssh-copy-id -i "$public_key" "$user@$host" -y
#     EOF
#   }
# }

resource "null_resource" "ansible_inventory" {
  depends_on = [module.linuxvm]
  # depends_on = [null_resource.ssh_key_setup]
  provisioner "local-exec" {
    command = <<-EOF
      echo "[zabbixs]
      zabbix ansible_host=${module.linuxvm.ip[0]} ansible_user=it ansible_ssh_pass=it ansible_become_pass=it ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" > ansible/hosts.ini
      EOF
  }
}
resource "null_resource" "run_ansible" {
  depends_on = [null_resource.ansible_inventory]
  provisioner "local-exec" {
    command = "ansible-playbook -i hosts.ini playbook.yml"
    working_dir = "${path.module}/ansible/"
  }
}

