#!/bin/bash
#
#
# sudo su


apt-get -y update
# ufw
ufw allow 25,80,443,465,587,8080,60000:65535/tcp
# Nginx
apt install -y nginx
apt install -y php7.4-cli php7.4-fpm php7.4-curl php7.4-gd php7.4-mysql php7.4-mbstring zip unzip

systemctl enable nginx



# Сперва настраиваем системное время
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


# sdfsw 2111 23  

xdg-open http://127.0.1.1/








# Sandbox
# echo "question?"[y/N]
# read agree
# echo "Answer" 