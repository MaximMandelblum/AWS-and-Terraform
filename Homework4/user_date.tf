
locals {
  my-instance-userdata = <<USERDATA
#!/bin/bash
IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
sudo apt update
sudo apt install nginx -y
sed -i 's/nginx/OpsSchool userip: '$IP' great you here with us!!/g' /var/www/html/index.nginx-debian.html
sed -i '15,23d' /var/www/html/index.nginx-debian.html
service nginx restart
USERDATA
}
