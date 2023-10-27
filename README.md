# Trên đây là toàn bộ LAB về triển khai VM trên các host bằng Vagrant kết hợp với Ansible để triển khai các dịch vụ trên VM
Trên đây là toàn bộ các bước thực hiện trên Virtualbox.
Để thực hiện một cách hiệu quả cần phải cài đặt trước các yêu cầu như sau:
Cài đặt VirtualBox:
1. Máy tương tác là Ubuntu (chưa test trên môi trường Windows).
	Ở đây sử dụng Ubuntu Desktop 20.04

2. Tải VirtualBox từ trang chính thức: "https://www.virtualbox.org/" Sau khi tải xong, cài đặt VirtualBox bằng cách chạy tệp tải về.
	Hoặc cài Virtualbox trên terminal của Unbuntu

		`sudo apt update
		sudo apt install virtualbox
		virtualbox --version`

3. Cài đặt Vagrant:
	Tải Vagrant từ trang chính thức: https://www.vagrantup.com/ Cài đặt Vagrant bằng cách chạy tệp tải về.
	Hoặc cài Vagrant trên terminal của Unbuntu

	`wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
		echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
		sudo apt update && sudo apt install vagrant`

4. Cài đặt Ansible: 
	thực hiện các command sau (lưu ý đây là thực hiện trên Ubuntu 20.04):

		`sudo apt update
		sudo apt install ansible
		sudo apt install ansible`
