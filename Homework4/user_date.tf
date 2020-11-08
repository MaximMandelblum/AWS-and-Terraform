
locals {
  my-instance-userdata = <<USERDATA
#!/bin/bash
sudo apt update
sudo apt install nginx -y
sed -i 's/nginx/Welcome to my private page of Opsschool Course/g' /var/www/html/index.nginx-debian.html
sed -i '15,23d' /var/www/html/index.nginx-debian.html
service nginx restart
USERDATA
}
