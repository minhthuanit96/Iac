# Terraform Timeout Configuration

## Problem

When creating VMs with the bpg provider, Terraform may hang waiting for the VM to report its IP address through the QEMU guest agent. This can cause the script to appear stuck even though the VM has been created successfully.

## Solutions Implemented

### 1. **Timeout Configuration**

Added to both projects in `main.tf`:

```hcl
resource "proxmox_virtual_environment_vm" "vm" {
  # ... other configuration ...
  
  # Prevents Terraform from waiting indefinitely
  timeout_create = "10m"
  
  # Ensures VM starts immediately
  started = true
}
```

This ensures Terraform will:
- Only wait up to 10 minutes for the VM to be created
- Exit with the VM information even if the IP isn't immediately available
- Start the VM automatically

### 2. **Better Output Handling**

Updated `outputs.tf` to gracefully handle missing IP addresses:

```hcl
output "vm_ip" {
  value = try(
    proxmox_virtual_environment_vm.vm.ipv4_addresses[1][0],
    "Check Proxmox console for IP"
  )
}
```

Now instead of hanging, you'll see a helpful message if the IP isn't ready yet.

### 3. **Manual IP Retrieval**

If Terraform completes but shows "Check Proxmox console for IP":

#### Option A: Terraform Refresh
```bash
terraform refresh
terraform output vm_ip
```

#### Option B: Check Proxmox Web UI
1. Open Proxmox web interface
2. Navigate to your VM
3. Look for the IP in the Summary tab

#### Option C: Check from Proxmox SSH
```bash
qm guest cmd <VM_ID> network-get-interfaces
```

### 4. **QEMU Guest Agent**

The IP address detection relies on the QEMU guest agent. Ensure:

1. **Agent is installed in template:**
   ```bash
   sudo apt install qemu-guest-agent
   sudo systemctl enable qemu-guest-agent
   sudo systemctl start qemu-guest-agent
   ```

2. **Agent is enabled in Terraform** (already configured):
   ```hcl
   agent {
     enabled = true
   }
   ```

## Troubleshooting

### If Terraform still hangs:

1. **Check agent status** in the VM:
   ```bash
   ssh ubuntu@<IP>
   systemctl status qemu-guest-agent
   ```

2. **Increase timeout** if needed in `main.tf`:
   ```hcl
   timeout_create = "15m"  # Increase from 10m
   ```

3. **Use DHCP** instead of static IP (temporarily):
   ```hcl
   vm_ip_address = "dhcp"
   vm_gateway    = ""
   ```

### If you need to cancel a stuck apply:

```bash
# Press Ctrl+C once (gracefully)
# Or Ctrl+C twice (force exit)

# Then check Proxmox to see if VM was created
```

## Best Practices

1. **Template preparation:**
   - Install qemu-guest-agent
   - Test cloud-init works
   - Verify network configuration

2. **Network configuration:**
   - Use DHCP first to verify everything works
   - Then switch to static IPs

3. **Monitoring:**
   - Watch Proxmox console during first deployment
   - Check VM logs if issues occur

4. **Deployment workflow:**
   ```bash
   terraform plan    # Review changes
   terraform apply   # Will timeout after 10 minutes
   
   # If IP not shown:
   sleep 60          # Wait for cloud-init
   terraform refresh # Get latest state
   terraform output  # Show all outputs
   ```

## Changes Made

### Main Project (`proxmox-terraform-ansible/terraform/`)
- ✅ Added `timeout_create = "10m"` to `main.tf`
- ✅ Added `started = true` to `main.tf`
- ✅ Updated `outputs.tf` with better error handling
- ✅ Added `vm_ready_check` output with instructions

### Snipe-IT Example (`examples/snipeit-deployment/terraform/`)
- ✅ Added `timeout_create = "10m"` to `main.tf`
- ✅ Added `started = true` to `main.tf`
- ✅ Updated `outputs.tf` with graceful IP handling
- ✅ Improved `next_steps` output

## Expected Behavior Now

```bash
$ terraform apply

# ... creation process ...

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

vm_id = "123"
vm_ip = "192.168.1.100"  # Or "Check Proxmox console for IP"
vm_name = "webserver-01"
vm_ssh_host = "ubuntu@192.168.1.100"

# If IP not ready, run:
$ terraform refresh
$ terraform output vm_ip
# => "192.168.1.100"
```

The script will now **exit normally** even if the IP isn't immediately available!
