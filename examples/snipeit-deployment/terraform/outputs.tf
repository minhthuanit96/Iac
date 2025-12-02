output"vm_id" {
  description = "VM ID"
  value       = proxmox_virtual_environment_vm.snipeit.id
}

output "vm_name" {
  description = "VM name"
  value       = proxmox_virtual_environment_vm.snipeit.name
}

output "vm_ip" {
  description = "VM IP address"
  value       = try(
    proxmox_virtual_environment_vm.snipeit.ipv4_addresses[1][0],
    "Check Proxmox console for IP"
  )
}

output "ssh_command" {
  description = "SSH connection command"
  value       = "ssh ${var.vm_user}@${try(proxmox_virtual_environment_vm.snipeit.ipv4_addresses[1][0], "GET_IP_FROM_PROXMOX")}"
}

output "snipeit_url" {
  description = "Snipe-IT web interface URL"
  value       = "http://${try(proxmox_virtual_environment_vm.snipeit.ipv4_addresses[1][0], "GET_IP_FROM_PROXMOX")}"
}

output "ansible_inventory" {
  description = "Ansible inventory entry"
  value       = "${var.vm_name} ansible_host=${try(proxmox_virtual_environment_vm.snipeit.ipv4_addresses[1][0], "GET_IP_FROM_PROXMOX")} ansible_user=${var.vm_user}"
}

output "next_steps" {
  description = "What to do next"
  value       = <<-EOT
  
  ✅ VM Deployed Successfully!
  
  Next steps:
  1. Wait 1-2 minutes for cloud-init to complete
  2. Check VM IP in Proxmox web UI if not shown above
  3. Test SSH: ssh ${var.vm_user}@<VM_IP>
  4. Run Ansible playbook to install Snipe-IT
  5. Access Snipe-IT at: http://<VM_IP>
  
  To get the IP address if not showing:
  - Run: terraform refresh
  - Or check Proxmox web UI
  
  EOT
}
