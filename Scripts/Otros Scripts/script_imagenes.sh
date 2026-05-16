#!/bin/bash
## Este script copia imagenes a contenedores docker
echo --------------- IMAGENES ARAI	USUARIOS ---------------
x=$(docker ps --format "{{.Names}}" | grep 'usuarios_idp.')
y=$(echo $x | tr " " "\n")  ##Imprime la variable anterior, la redirige con pipe y translate reemplaza cada espacio "  " por un salto de linea "|n" 
count=1
for dirArai in $y
do
        echo $count")" $dirArai
        #### Cambiamos las imagenes ####
        docker cp /opt/img/logo.png $dirArai:/usr/local/app/idp/simplesamlphp-module-arai/www/assets/img/
        docker cp /opt/img/logo_cin.png $dirArai:/usr/local/app/idp/simplesamlphp-module-arai/www/assets/img/
        docker cp /opt/img/fondo.png $dirArai:/usr/local/app/idp/simplesamlphp-module-arai/www/assets/img/

        #### Sacamos imagen logo_cin.png ####
        docker cp /opt/img/_logo.twig $dirArai:/usr/local/app/idp/simplesamlphp-module-arai/templates/
        docker exec -it $dirArai chown apache:apache /usr/local/app/idp/simplesamlphp-module-arai/templates/_logo.twig

        #### Cambiamos los estilos ####
        docker cp /opt/img/stylesheet.css $dirArai:/usr/local/app/idp/simplesamlphp-module-arai/www/assets/css/
        docker exec -it $dirArai chown apache:apache /usr/local/app/idp/simplesamlphp-module-arai/www/assets/css/stylesheet.css
        count=$(($count + 1))

done


echo --------------- IMAGENES HUARPE ------------------
x=$(docker ps --format "{{.Names}}" | grep 'huarpe_webapp')
y=$(echo $x | tr " " "\n")
count=1
for dirHuarpe in $y
do
        echo $count")" $dirHuarpe
        docker cp /opt/img/logo-cin-blanco.png $dirHuarpe:/usr/local/app/public/img/logos/
        docker cp /opt/img/logo-cin-blanco.png $dirHuarpe:/usr/local/app/public/img/logos/
        docker cp /opt/img/logo-huarpe.png $dirHuarpe:/usr/local/app/public/img/logos/

        count=$(($count + 1))
done
