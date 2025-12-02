#!/bin/bash

# Snipe-IT Deployment Script
# Automates the full deployment of Snipe-IT on Proxmox

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${BLUE}$1${NC}"; }

TERRAFORM_DIR="./terraform"
ANSIBLE_DIR="./ansible"

echo ""
print_header "======================================"
print_header "  Snipe-IT Deployment Automation"
print_header "======================================"
echo ""

# Check prerequisites
check_prereqs() {
    print_info "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform not installed"
        exit 1
    fi
    
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible not installed"
        exit 1
    fi
    
    print_info "Prerequisites OK"
}

# Deploy with Terraform
deploy_vm() {
    print_header "\n=== Phase 1: Deploying VM with Terraform ==="
    
    cd "$TERRAFORM_DIR"
    
    if [ ! -f "terraform.tfvars" ]; then
        print_error "terraform.tfvars not found"
        print_warn "Copy terraform.tfvars.example and configure it"
        exit 1
    fi
    
    print_info "Initializing Terraform..."
    terraform init
    
    print_info "Planning deployment..."
    terraform plan
    
    echo ""
    read -p "Apply this plan? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_warn "Deployment cancelled"
        exit 0
    fi
    
    print_info "Deploying VM..."
    terraform apply -auto-approve
    
    VM_IP=$(terraform output -raw vm_ip 2>/dev/null || echo "")
    
    cd ..
    
    if [ -z "$VM_IP" ]; then
        print_error "Could not get VM IP"
        exit 1
    fi
    
    print_info "VM deployed successfully at $VM_IP"
}

# Wait for SSH
wait_ssh() {
    print_header "\n=== Waiting for VM to be ready ==="
    
    cd "$TERRAFORM_DIR"
    VM_IP=$(terraform output -raw vm_ip)
    cd ..
    
    print_info "Waiting for SSH on $VM_IP..."
    
    for i in {1..30}; do
        if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "ubuntu@${VM_IP}" "exit" 2>/dev/null; then
            print_info "SSH is ready!"
            return 0
        fi
        echo -n "."
        sleep 10
    done
    
    print_error "SSH timeout"
    exit 1
}

# Update inventory
update_inventory() {
    print_info "Updating Ansible inventory..."
    
    cd "$TERRAFORM_DIR"
    VM_IP=$(terraform output -raw vm_ip)
    VM_NAME=$(terraform output -raw vm_name)
    cd ..
    
    cat > "${ANSIBLE_DIR}/inventory.ini" << EOF
# Auto-generated inventory
[snipeit]
${VM_NAME} ansible_host=${VM_IP} ansible_user=ubuntu

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
    
    print_info "Inventory updated"
}

# Deploy Snipe-IT
deploy_snipeit() {
    print_header "\n=== Phase 2: Installing Snipe-IT with Ansible ==="
    
    cd "$ANSIBLE_DIR"
    
    print_info "Testing connectivity..."
    ansible snipeit -m ping
    
    print_info "Installing Snipe-IT (this may take 5-10 minutes)..."
    ansible-playbook playbook.yaml
    
    cd ..
}

# Show completion message
show_completion() {
    print_header "\n======================================"
    print_header "  Deployment Complete!"
    print_header "======================================"
    
    cd "$TERRAFORM_DIR"
    VM_IP=$(terraform output -raw vm_ip)
    cd ..
    
    echo ""
    print_info "Snipe-IT is now accessible at: http://${VM_IP}"
    echo ""
    echo "Next steps:"
    echo "  1. Open http://${VM_IP} in your browser"
    echo "  2. Complete the setup wizard"
    echo "  3. Create your admin account"
    echo "  4. Start managing your assets!"
    echo ""
    print_info "See README.md for more information"
    echo ""
}

# Main menu
show_menu() {
    echo ""
    echo "Select operation:"
    echo "  1) Full deployment (Terraform + Ansible)"
    echo "  2) Deploy VM only (Terraform)"
    echo "  3) Install Snipe-IT only (Ansible)"
    echo "  4) Destroy everything"
    read -p "Enter choice [1-4]: " choice
    
    case $choice in
        1)
            check_prereqs
            deploy_vm
            wait_ssh
            update_inventory
            deploy_snipeit
            show_completion
            ;;
        2)
            check_prereqs
            deploy_vm
            ;;
        3)
            check_prereqs
            deploy_snipeit
            ;;
        4)
            print_warn "This will destroy the VM and all data!"
            read -p "Type 'yes' to confirm: " confirm
            if [ "$confirm" == "yes" ]; then
                cd "$TERRAFORM_DIR"
                terraform destroy
                cd ..
                print_info "Destroyed"
            fi
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
}

# Run
show_menu
