#!/bin/bash

#Al ejecutarse este script actualiza MYSQL client de 5.6 a 5.7 y el devel

#  Descargar el paquete mysql-community-client 5.7.44
echo "Descargando mysql-community-client 5.7.44..."
wget -c http://panel.net/panel/panel-Platform/MySQL-5.7/mysql-community-client-5.7.44-1.el6.x86_64.rpm

#  Instalar el repositorio de MySQL 8.0 para CentOS 7
echo "Instalando repositorio MySQL 8.0..."
yum -y install https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm

# Deshabilitar el repositorio MySQL 8.0 y habilitar el repositorio MySQL 5.7
echo "Deshabilitando repositorio MySQL 8.0 y habilitando MySQL 5.7..."
yum-config-manager --disable mysql80-community >/dev/null
yum-config-manager --enable mysql57-community >/dev/null

#  Eliminar archivo de configuración antiguo si existe
echo "Eliminando archivo de configuración antiguo..."
rm -vf /etc/yum.repos.d/mysql-community.repo.rpmsave

# Reemplazar la llave pública de MySQL 
echo "Reemplazando la llave pública de MySQL..."
cat <<EOF > /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
-----BEGIN PGP PUBLIC KEY BLOCK-----
.........
-----END PGP PUBLIC KEY BLOCK-----
EOF

yum remove -y mysql-devel

# Instalar el cliente de MySQL 5.7
echo "Instalando mysql-community-client..."
yum -y install mysql-community-client 

## --disablerepo=imunify360-alt-php --disablerepo=elrepo

yum install -y mysql-community-devel

ln -s /usr/lib64/mysql/libmysqlclient.so.20 /usr/lib64/mysql/libmysqlclient.so
ldconfig

rm -f /root/actualizar_mysql57.sh
