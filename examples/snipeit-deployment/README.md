# Snipe-IT Deployment Example

This is a complete, ready-to-use example that deploys a VM on Proxmox and installs [Snipe-IT](https://snipeitapp.com/), an open-source IT asset management system.

## 📋 What Gets Deployed

This example demonstrates:

1. **Infrastructure**: VM provisioned on Proxmox with Terraform
2. **LAMP Stack**: Apache, MySQL, PHP 8.1 configured via Ansible
3. **Snipe-IT**: Latest stable version installed and configured
4. **Security**: Firewall configured, MySQL secured

## 🎯 Prerequisites

- Proxmox VE server with API access
- Ubuntu 22.04 cloud-init template
- Terraform installed
- Ansible installed (use WSL on Windows - see [WINDOWS_SETUP.md](../../proxmox-terraform-ansible/WINDOWS_SETUP.md))
- SSH key pair

## 🚀 Quick Start

### Step 1: Configure Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your details:

```hcl
proxmox_api_url = "https://your-proxmox:8006/api2/json"
proxmox_user    = "root@pam"
proxmox_password = "your-password"
proxmox_node    = "pve"
template_name   = "ubuntu-22.04-cloudinit"

vm_name       = "snipeit-server"
vm_ip_config  = "ip=192.168.1.150/24,gw=192.168.1.1"
ssh_public_key = "ssh-rsa AAAAB... your-key"

snipeit_app_url     = "http://192.168.1.150"
snipeit_db_password = "YourSecurePassword123!@#"
```

### Step 2: Deploy the VM

```bash
terraform init
terraform plan
terraform apply
```

**Note the VM IP address** from the output!

### Step 3: Configure Ansible Inventory

Edit `../ansible/inventory.ini`:

```ini
[snipeit]
snipeit-server ansible_host=192.168.1.150 ansible_user=ubuntu
```

Or auto-generate from Terraform:

```bash
terraform output -raw ansible_inventory >> ../ansible/inventory.ini
```

### Step 4: Install Snipe-IT with Ansible

```bash
cd ../ansible

# Test connectivity
ansible snipeit -m ping

# Deploy Snipe-IT
ansible-playbook playbook.yaml
```

This will take 5-10 minutes to:
- Update the system
- Install LAMP stack
- Download and configure Snipe-IT
- Set up the database
- Configure Apache

### Step 5: Access Snipe-IT

Open your browser and navigate to: `http://YOUR_VM_IP`

Complete the initial setup wizard:

1. **Pre-flight check**: Should all be green ✅
2. **Create Admin Account**:
   - First Name: Your name
   - Last Name: Your last name
   - Email: your@email.com
   - Username: admin (or your choice)
   - Password: (create a secure password)
3. **Site Settings**: Configure your organization details
4. **Done!** Start managing your assets

## 📊 What's Installed

### System Packages
- Apache 2.4 web server
- MySQL 8.0 database
- PHP 8.1 with required extensions
- Git, Composer, and build tools

### Snipe-IT Configuration
- Latest stable version (v6.3.0)
- Installed at: `/var/www/snipeit`
- Database: `snipeit`
- Web server: Apache with mod_rewrite

### Security
- UFW firewall enabled (ports 22, 80, 443 open)
- MySQL secured (no anonymous users, no test database)
- Root password protected

## 🔧 Customization

### Change Snipe-IT Version

Edit `ansible/playbook.yaml`:

```yaml
snipeit_version: "v6.2.0"  # Or any valid tag
```

### Use a Custom Domain

1. Set up DNS A record pointing to VM IP
2. Update `terraform.tfvars`:
   ```hcl
   snipeit_app_url = "http://snipeit.yourdomain.com"
   ```
3. Redeploy or manually update `/var/www/snipeit/.env`

### Enable HTTPS

After deployment, install Let's Encrypt:

```bash
ssh ubuntu@YOUR_VM_IP
sudo apt install certbot python3-certbot-apache
sudo certbot --apache -d snipeit.yourdomain.com
```

### Adjust VM Resources

Edit `terraform.tfvars`:

```hcl
vm_cores     = 4      # More CPU for larger deployments
vm_memory    = 8192   # More RAM for better performance
vm_disk_size = "100G" # More storage for attachments
```

Then run `terraform apply` to update.

## 🔐 Default Credentials

### MySQL Root
- Username: `root`
- Password: Set in `playbook.yaml` (default: `RootPassword123!@#`)

### Snipe-IT Database
- Database: `snipeit`
- Username: `snipeituser`
- Password: Set in `playbook.yaml` (matches `snipeit_db_password`)

### Snipe-IT Admin
- Created during the web setup wizard
- You choose the username and password

## 📝 Post-Installation

### Recommended Next Steps

1. **Change default passwords** in `playbook.yaml` before deployment
2. **Configure email** in Snipe-IT settings (for notifications)
3. **Set up backups**:
   ```bash
   # Database backup
   ssh ubuntu@YOUR_VM_IP
   mysqldump -u root -p snipeit > snipeit_backup.sql
   
   # File backup
   sudo tar -czf snipeit_files.tar.gz /var/www/snipeit
   ```
4. **Configure LDAP/SAML** if needed (Settings > LDAP)
5. **Import assets** or start adding them manually

### Accessing Logs

```bash
ssh ubuntu@YOUR_VM_IP

# Apache logs
sudo tail -f /var/log/apache2/snipeit_error.log

# Snipe-IT logs
sudo tail -f /var/www/snipeit/storage/logs/laravel.log
```

## 🛠️ Troubleshooting

### Can't access Snipe-IT web interface

```bash
# Check Apache status
sudo systemctl status apache2

# Check firewall
sudo ufw status

# Test from VM
curl localhost
```

### Database connection errors

```bash
# Check MySQL status
sudo systemctl status mysql

# Verify database exists
mysql -u root -p -e "SHOW DATABASES;"

# Check .env file
cat /var/www/snipeit/.env | grep DB_
```

### Permission errors

```bash
# Fix permissions
cd /var/www/snipeit
sudo chown -R www-data:www-data storage public/uploads bootstrap/cache
sudo chmod -R 775 storage public/uploads bootstrap/cache
```

### Reset admin password

```bash
ssh ubuntu@YOUR_VM_IP
cd /var/www/snipeit
php artisan snipeit:create-admin
```

## 🗑️ Cleanup

To destroy the VM and all resources:

```bash
cd terraform
terraform destroy
```

## 📚 Learn More

- [Snipe-IT Documentation](https://snipe-it.readme.io/)
- [Snipe-IT GitHub](https://github.com/snipe/snipe-it)
- [Installation Requirements](https://snipe-it.readme.io/docs/requirements)

## 💡 Tips

- **Performance**: For production use, consider 4GB+ RAM and 2+ CPU cores
- **Storage**: Plan for file uploads - users will attach images and documents
- **Backups**: Schedule regular database and file backups
- **Updates**: Check Snipe-IT releases regularly for security updates
- **Mobile**: Snipe-IT has a responsive design and mobile apps available

## 📧 Snipe-IT Features

Once deployed, you can:

- Track IT assets (laptops, servers, licenses, etc.)
- Manage check-in/check-out of equipment
- Track asset history and maintenance
- Generate reports and audit logs
- Manage licenses and software
- Track depreciations
- Asset labels and QR codes
- Email notifications
- LDAP/SAML integration
- API access for automation

---

**Project Structure**:
```
snipeit-deployment/
├── terraform/          # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
└── ansible/           # Configuration Management
    ├── ansible.cfg
    ├── inventory.ini
    ├── playbook.yaml
    └── roles/
        ├── common/    # System setup
        ├── lamp/      # Web stack
        └── snipeit/   # Application install
```
