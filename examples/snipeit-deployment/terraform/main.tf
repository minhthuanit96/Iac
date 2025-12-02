terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.50.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  username = var.proxmox_user
  password = var.proxmox_password
  insecure = var.proxmox_tls_insecure
  
  ssh {
    agent = true
  }
}

# Snipe-IT VM
resource "proxmox_virtual_environment_vm" "snipeit" {
  name      = var.vm_name
  node_name = var.proxmox_node
  
  # Clone from template
  clone {
    vm_id = var.template_id
  }
  
  # Snipe-IT recommended specs
  cpu {
    cores   = var.vm_cores
    sockets = 1
  }
  
  memory {
    dedicated = var.vm_memory
  }
  
  agent {
    enabled = true
  }
  
  boot_order = ["scsi0"]
  on_boot    = true
  
  # Disk - Snipe-IT needs space for uploads and backups
  disk {
    datastore_id = var.vm_storage
    interface    = "scsi0"
    size         = var.vm_disk_size
    file_format  = "raw"
    ssd          = true
  }
  
  # Network
  network_device {
    bridge = var.vm_network_bridge
    model  = "virtio"
  }
  
  # Cloud-Init
  initialization {
    ip_config {
      ipv4 {
        address = var.vm_ip_address
        gateway = var.vm_gateway
      }
    }
    
    dns {
      servers = var.vm_dns_servers
    }
    
    user_account {
      username = var.vm_user
      keys     = [var.ssh_public_key]
    }
  }
  
  # Startup configuration
  started = true
  
  # Timeout settings - prevents hanging
  timeout_create = "10m"
  
  lifecycle {
    ignore_changes = [network_device]
  }
}
