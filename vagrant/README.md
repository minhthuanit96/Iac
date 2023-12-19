# Vagrant and Ansible
## _make anything quickly_


Above is the entire LAB about deploying VMs on hosts using Vagrant combined with Ansible to deploy services on VMs.
My purpose is to deloy VMs quickly and smooothly
-------------------------------------------- ✨THUANNGUYENIT ✨-----------------------------------------------

## Installation

To do this effectively, the following requirements must be installed in advance:

You deloy VMs on Virtual Box so you need prepare a host with Virtual box is installed.
In my case, I want to deloy VMs on Ubuntu desktop 20.04.


Install Virtual box.
You can download installation file from website [Virtual Box](https://www.virtualbox.org/) and install the download file or install by below command

```sh
sudo apt update
sudo apt install virtualbox
virtualbox --version
```

Install Vagrant.
You can download installation file from website [Vagrant](https://www.vagrantup.com/) and install the download file or install by below command

```sh
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list sudo apt update && sudo apt install vagrant
```

Install Ansible
Execute the following commands (note this is done on Ubuntu 20.04):
```sh
sudo apt update
sudo apt install ansible
sudo apt install ansible
```