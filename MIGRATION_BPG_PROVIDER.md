# Migration from Telmate to bpg Proxmox Provider

## Changes Summary

Both the main project and Snipe-IT example have been updated to use the **bpg/proxmox** provider, which provides better support for Proxmox 8.x.

## Key Differences

### Provider Configuration

**Before (Telmate):**
```hcl
provider "proxmox" {
  pm_api_url      = "https://proxmox:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = "password"
  pm_tls_insecure = true
}
```

**After (bpg):**
```hcl
provider "proxmox" {
  endpoint = "https://proxmox:8006"
  username = "root@pam"
  password = "password"
  insecure = true
}
```

### Resource Name

- **Before:** `proxmox_vm_qemu`
- **After:** `proxmox_virtual_environment_vm`

### Template Reference

- **Before:** Uses template name (string)
- **After:** Uses template VM ID (number)

You need to find your template's VM ID in Proxmox (e.g., 9000).

### Network Configuration

**Before (Telmate):**
```hcl
vm_ip_config  = "ip=192.168.1.100/24,gw=192.168.1.1"
vm_nameserver = "8.8.8.8 8.8.4.4"
```

**After (bpg):**
```hcl
vm_ip_address  = "192.168.1.100/24"
vm_gateway     = "192.168.1.1"
vm_dns_servers = ["8.8.8.8", "8.8.4.4"]
```

### Disk Size

- **Before:** String with unit (e.g., `"20G"`)
- **After:** Number in GB (e.g., `20`)

## Migration Steps

1. **Update terraform.tfvars:**
   - Change `proxmox_api_url` to remove `/api2/json`
   - Change `template_name` to `template_id` with VM ID number
   - Split `vm_ip_config` into `vm_ip_address`, `vm_gateway`
   - Change `vm_nameserver` to `vm_dns_servers` (list)
   - Change `vm_disk_size` from `"20G"` to `20`

2. **Find your template VM ID:**
   ```bash
   # On Proxmox server
   qm list | grep ubuntu
   ```

3. **Reinitialize Terraform:**
   ```bash
   cd terraform
   rm -rf .terraform .terraform.lock.hcl
   terraform init
   terraform plan
   ```

## Example Configuration

See `terraform.tfvars.example` in both projects for complete examples.

## Benefits of bpg Provider

- ✅ Full Proxmox 8.x support
- ✅ More reliable API implementation
- ✅ Better error messages
- ✅ Active development and maintenance
- ✅ Cleaner resource structure
- ✅ Better cloud-init support

## Updated Files

### Main Project (`proxmox-terraform-ansible/terraform/`)
- `main.tf` - Provider and VM resource
- `variables.tf` - Variable definitions
- `outputs.tf` - Output values
- `terraform.tfvars.example` - Example configuration

### Snipe-IT Example (`examples/snipeit-deployment/terraform/`)
- `main.tf` - Provider and VM resource
- `variables.tf` - Variable definitions
- `outputs.tf` - Output values
- `terraform.tfvars.example` - Example configuration
