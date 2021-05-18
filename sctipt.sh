#!/bin/bash
#
#
# sudo su
apt-get -y update
# ufw
ufw allow 22,25,80,443,465,587,8080,60000:65535/tcp
# Nginx
apt install -y nginx
apt install -y php7.4-cli php7.4-fpm php7.4-curl php7.4-gd php7.4-mysql php7.4-mbstring zip unzip
systemctl enable nginx

rm /etc/nginx/sites-enabled/default
wget --no-check-certificate --content-disposition -P /etc/nginx/sites-enabled/ https://raw.githubusercontent.com/KillingNature/configs/main/default.conf
echo -e "\e[31mВведите полное имя домена:\e[0m"
read DOMAIN
mkdir /var/www/$DOMAIN
adduser $USER www-data
chown -R www-data:www-data /var/www/$DOMAIN
chmod -R g+rw /var/www/$DOMAIN
echo '<?php phpinfo(); ?>' >> /var/www/$DOMAIN/index.php
apt-get install -y mariadb-server
systemctl enable mariadb
echo -e "\e[31mЗадайте пароль для для root на БД:\e[0m"
mysqladmin -u root password
apt-get install -y php-mysql
apt-get install -y phpmyadmin #Криво устанавливается
wget --no-check-certificate --content-disposition -P /etc/nginx/sites-enabled/ https://raw.githubusercontent.com/KillingNature/configs/main/phpmyadmin.conf
sed -i -e "s/#Name/php.$DOMAIN/g" /etc/nginx/sites-enabled/phpmyadmin.conf
my_ip=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}') #IP устройства
sed -i "1s/^/$my_ip $DOMAIN\n/" /etc/hosts
sed -i -e "s/#Name/$DOMAIN/g" /etc/nginx/sites-enabled/default.conf
systemctl reload nginx
apt-get install -y memcached php-memcached
systemctl enable memcached
systemctl restart php7.4-fpm
systemctl restart nginx


#  настраиваем системное время
apt-get install -y chrony
systemctl enable chrony -y
timedatectl set-timezone Asia/Yekaterinburg









# Устанавливаем ftp сервер (vsftpd)  КОНФИГ здесь:    /etc/vsftpd.conf
sudo apt-get install -y vsftpd
#Ports - ?
echo "Использовать стандартный диапазон портов?[y/N]"
read agree
case "$agree" in
    y|Y) break
        ;;
    n|N) 
    echo "Введите начало диапазона:"
    read PORT1
    echo "Введите конец диапазона:"
    read PORT2
    echo "Выбран диапазон портов" $PORT1 ":" $PORT2
    echo "pasv_enable=Yes" >> /etc/vsftpd.conf
    echo "pasv_min_port="$PORT1  >> /etc/vsftpd.conf
    echo "pasv_max_port="$PORT2 >> /etc/vsftpd.conf
        
        ;;
    *) 
        break
        ;;
esac
ufw allow 20,21,$PORT1:$PORT2/tcp


echo "Разрешить использование IPv6? [Y/N]" #по дефолту - разрешен
read  agree
case "$agree" in 
    y|Y) STATUS=YES
        ;;
    n|N) STATUS=NO
        ;;
    *)  STATUS=NO
        ;;
esac
echo $STATUS
systemctl enable vsftpd
# 
# РАЗОБРАТЬСЯ С КОМАНДОЙ sed  !!!
# sed -i -e "/s/listen_ipv6=*/listen_ipv6= $STATUS"   /etc/vsftpd.conf
# 



echo "Разрешить передачу данных через TLS? [Y/N]"
read agree 
echo "ssl_tlsv1=YES" >> /etc/vsftpd.conf

#Создаем пользователя
echo -e "\e[31mУкажите имя FTP пользователя:\e[0m"
read USER
adduser  $USER

mkdir /home/sammy/ftp
chown nobody:nogroup /home/sammy/ftp
chmod a-w /home/sammy/ftp


echo "chroot_local_user=YES" >> /etc/vsftpd.conf
echo "user_sub_token=$USER" >> /etc/vsftpd.conf
echo "local_root=/home/$USER/ftp" >> /etc/vsftpd.conf

echo -e     "userlist_enable=YES
            \nuserlist_file=/etc/vsftpd.userlist
            \nuserlist_deny=NO"                        >> /etc/vsftpd.conf  



systemctl restart vsftpd

echo -e "\e[31mДобавьте вручную $my_ip $DOMAIN и $my_ip php.$DOMAIN в файл hosts\e[0m"
        
# Проверка сервера в GUI:
# xdg-open http://$DOMAIN

# Sandbox
# sed -i -e "/s/listen_ipv6=*/listen_ipv6= $STATUS"   /etc/vsftpd.conf

# sed -i -e "/s/listen_ipv6=*/listen_ipv6= $STATUS"   /etc/vsftpd.conf