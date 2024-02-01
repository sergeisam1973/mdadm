#!/usr/bin/bash
# Создаем RAID5 из 5 блочных устройств:
sudo mdadm --create -l 5 -n 5 /dev/md0 /dev/sd{b,c,d,e,f}
# Создаем конфигурационный файл mdadm.conf:
sudo mkdir /etc/mdadm
echo "DEVICE partitions" | sudo tee /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan | sudo awk '/ARRAY/ {print}' | sudo tee -a /etc/mdadm/mdadm.conf
# Создаем раздел GPT на RAID-массиве:
sudo parted -s /dev/md0 mklabel gpt
# Создаем 5 партиций равного объема:
sudo parted /dev/md0 mkpart primary 0% 20%
sudo parted /dev/md0 mkpart primary 20% 40%
sudo parted /dev/md0 mkpart primary 40% 60%
sudo parted /dev/md0 mkpart primary 60% 80%
sudo parted /dev/md0 mkpart primary 80% 100%
# Создаем на всех партициях файловые системы:
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
# Создаем каталоги и монтируем к ним файловые системы:
sudo mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done
# Обеспечиваем автоматическое монтирование при перезагрузке ОС:
for i in $(seq 1 5); do echo "/dev/md0p$i /raid/part$i ext4 defaults 0 0" | sudo tee -a /etc/fstab; done
