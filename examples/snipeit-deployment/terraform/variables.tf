# Proxmox Connection
variable "proxmox_api_url" {
  description = "Proxmox API URL (e.g., https://proxmox.example.com:8006)"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox user"
  type        = string
  default     = "root@pam"
}

variable "proxmox_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "template_id" {
  description = "Cloud-init template VM ID"
  type        = number
}

# VM Configuration
variable "vm_name" {
  description = "VM name for Snipe-IT"
  type        = string
  default     = "snipeit-server"
}

variable "vm_cores" {
  description = "CPU cores (recommended: 2-4 for Snipe-IT)"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "RAM in MB (recommended: 4GB for Snipe-IT)"
  type        = number
  default     = 4096
}

variable "vm_disk_size" {
  description = "Disk size in GB (recommended: 40+ for Snipe-IT with uploads)"
  type        = number
  default     = 40
}

variable "vm_storage" {
  description = "Storage pool"
  type        = string
  default     = "local-lvm"
}

# Network
variable "vm_network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "vm_ip_address" {
  description = "IP address with CIDR (e.g., 192.168.1.150/24) or 'dhcp'"
  type        = string
  default     = "dhcp"
}

variable "vm_gateway" {
  description = "Gateway IP address"
  type        = string
  default     = ""
}

variable "vm_dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

# Cloud-Init
variable "vm_user" {
  description = "Default user"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}

# Snipe-IT Configuration
variable "snipeit_app_url" {
  description = "Snipe-IT application URL (e.g., http://snipeit.example.com or http://IP)"
  type        = string
}

variable "snipeit_db_password" {
  description = "MySQL password for Snipe-IT database"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!@#"
}
