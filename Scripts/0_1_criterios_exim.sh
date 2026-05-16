

##Dada la lista obtenida de servidores centos 7. Este script chequea los siguientes criterios para aplicar actualizacion de /exim en dedicados y arma una lista


###########################################################################################################################################
###perl-5.16.3-299.el7_9.x86_64                     ✓ perl --version
###python3-3.6.8-21.el7_9.x86_64                    ✓ python3 --version
###Exim version 4.93 #7                             ✓ /opt/exim/bin/exim -bV
###########################################################################################################################################
###CentOS Linux release 7.9.2009 (Core)          (Filtrado desde BO) 
###libmaxminddb-devel-1.2.0-6.el7.x86_64         (actualiza el script de subida yum install -y libmaxminddb libmaxminddb-devel)
###libmaxminddb-1.2.0-6.el7.x86_64               (actualiza el script de subida yum install -y libmaxminddb libmaxminddb-devel)
###########################################################################################################################################

# Lista de servidores destino
#!/bin/bash

SERVIDORES=(

)

echo -e "SERVIDOR\tPERL\tPYTHON3\tEXIM"

for srv in "${SERVIDORES[@]}"; do
    perl_v=$(ssh -o ConnectTimeout=5 "$srv" "perl -e 'print \$^V'" 2>/dev/null)

    python_v=$(ssh -o ConnectTimeout=5 "$srv" "python3 --version 2>/dev/null" \
               | cut -d' ' -f2)

    exim_v=$(ssh -o ConnectTimeout=5 "$srv" "/opt/exim/bin/exim -bV 2>/dev/null" \
               | head -n1)

    perl_v=${perl_v:-"-"}
    python_v=${python_v:-"-"}
    exim_v=${exim_v:-"-"}

    echo -e "${srv}\t${perl_v}\t${python_v}\t${exim_v}"
done
