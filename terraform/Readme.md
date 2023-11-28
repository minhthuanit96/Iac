Trên đây là toàn bộ code triển khai máy ảo trên Vpherse bằng Terraform và cài đặt zabbix bằng ansible lên máy ảo vừa tạo
1. Trước tiên cần tải và cài đặt Terraform và ansible. Chạy file install.sh
2. sau khi cài đặt xong ta chạy lệnh terraform --version và ansible --version để check xem 2 chương trình này đã được cài đặt chưa
3. sau khi xong ta chạy file terraform trên bằng cách sau
		terrform init # để khởi tạo môi trường cho terraform
		terrform apply # để chạy file main.tf tạo máy ảo
3. sau khi chạy xong sẽ sinh ra file hosts.ini trong thư mục ansible. Sau đó ta sử dụng lệnh ansible để tiếp tục triển khai zabbix trên máy ảo vừa tạo
		ansible-playbook -i hosts.ini playbook.yml -kK
		sau đó nhập ssh pass của template vm trước đó đã tạo cụ thể ở trong này template mật khẩu là "it" và become password là "it"
4. Ngồi chờ cài xong và thực hiện các bước cài đặt zabbix