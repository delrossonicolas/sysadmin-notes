#!/bin/bash
##Este script actualiza a mysql 8.0 importando la key

# Obtener la versión del cliente MySQL
cliente_version=$(mysql -V | awk '{ print $5 }' | sed 's/,//')

# Obtener la versión del servidor MySQL y eliminar cualquier parte extra como "-log"
servidor_version=$(mysql -e "SELECT @@version;" -s -N | sed 's/-log//g' | sed 's/;//')

# Deshabilitar MySQL 5.7 y habilitar MySQL 8.0
yum-config-manager --disable mysql57-community
yum-config-manager --enable mysql80-community

# Descargar e instalar el repositorio de MySQL 8.0
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
rpm -Uvh mysql80-community-release-el7-3.noarch.rpm

# Importar la clave GPG de MySQL
echo "-----BEGIN PGP PUBLIC KEY BLOCK-----
.........
-----END PGP PUBLIC KEY BLOCK-----" > /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

# Instalar MySQL Community Server
yum install -y mysql-community-client
echo "Borrando script..."
rm -- "$0"
