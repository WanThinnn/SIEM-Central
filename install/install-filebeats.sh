#!/bin/bash

# Cập nhật hệ thống
sudo apt update

# Cài đặt các gói cần thiết
sudo apt install -y apt-transport-https wget

# Tải xuống và cài đặt GPG key của Elastic
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# Thêm kho lưu trữ Elastic vào danh sách nguồn
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

# Cập nhật hệ thống để áp dụng thay đổi mới
sudo apt update

# Cài đặt Filebeat
sudo apt install -y filebeat

# Sao chép file cấu hình mẫu
sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak

# Bật dịch vụ Filebeat
sudo systemctl enable filebeat
sudo systemctl start filebeat