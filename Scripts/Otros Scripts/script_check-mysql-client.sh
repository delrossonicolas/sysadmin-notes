#!/bin/bash
##Este script chequea versiones de mysql

lista=(
array
)

for servidor in ${lista[@]}; do
    echo $servidor
    ssh -qt "$servidor" '
        MYSQL_VERSION=$(mysql -V)
        if echo "$MYSQL_VERSION" | egrep -q -v "5.7.44|8.0.41"; then
            echo "$MYSQL_VERSION"
        fi
        MYSQL_DEVEL=$(rpm -q MySQL-devel 2>&1)
        if echo "$MYSQL_DEVEL" | grep -q -v "is not installed"; then
            echo "$MYSQL_DEVEL"
        fi
        MYSQL_COMMUNITY_DEVEL=$(rpm -q mysql-community-devel 2>&1)
        if echo "$MYSQL_COMMUNITY_DEVEL" | egrep -q -v "mysql-community-devel-5.7.44|mysql-community-devel-8.0.41"; then
            echo "$MYSQL_COMMUNITY_DEVEL"
        fi
    '
    echo
done


echo

inicio=1
final=6

for (( i=inicio ; i<=final ; ++i ))
do
    servidor1="l00${i}a"
    servidor2="l00${i}b"

    echo $servidor1
    ssh -qt "$servidor1" '
        MYSQL_VERSION=$(mysql -V)
        if echo "$MYSQL_VERSION" | egrep -q -v "5.7.44|8.0.41"; then
            echo "$MYSQL_VERSION"
        fi
        MYSQL_DEVEL=$(rpm -q MySQL-devel 2>&1)
        if echo "$MYSQL_DEVEL" | grep -q -v "is not installed"; then
            echo "$MYSQL_DEVEL"
        fi
        MYSQL_COMMUNITY_DEVEL=$(rpm -q mysql-community-devel 2>&1)
        if echo "$MYSQL_COMMUNITY_DEVEL" | egrep -q -v "mysql-community-devel-5.7.44|mysql-community-devel-8.0.41"; then
            echo "$MYSQL_COMMUNITY_DEVEL"
        fi
    '
    echo

    echo $servidor2
    ssh -qt "$servidor2" '
        MYSQL_VERSION=$(mysql -V)
        if echo "$MYSQL_VERSION" | egrep -q -v "5.7.44|8.0.41"; then
            echo "$MYSQL_VERSION"
        fi
        MYSQL_DEVEL=$(rpm -q MySQL-devel 2>&1)
        if echo "$MYSQL_DEVEL" | grep -q -v "is not installed"; then
            echo "$MYSQL_DEVEL"
        fi
        MYSQL_COMMUNITY_DEVEL=$(rpm -q mysql-community-devel 2>&1)
        if echo "$MYSQL_COMMUNITY_DEVEL" | egrep -q -v "mysql-community-devel-5.7.44|mysql-community-devel-8.0.41"; then
            echo "$MYSQL_COMMUNITY_DEVEL"
        fi
    '
    echo
done
echo

inicio=130
final=277

for (( i=inicio ; i<=final ; ++i ))
do
    servidor1="c${i}a"
    servidor2="c${i}b"

    echo $servidor1

    ssh -qt "$servidor1" '
        MYSQL_VERSION=$(mysql -V)
        if echo "$MYSQL_VERSION" | egrep -q -v "5.7.44|8.0.41"; then
            echo "$MYSQL_VERSION"
        fi
        MYSQL_DEVEL=$(rpm -q MySQL-devel 2>&1)
        if echo "$MYSQL_DEVEL" | grep -q -v "is not installed"; then
            echo "$MYSQL_DEVEL"
        fi
        MYSQL_COMMUNITY_DEVEL=$(rpm -q mysql-community-devel 2>&1)
        if echo "$MYSQL_COMMUNITY_DEVEL" | egrep -q -v "mysql-community-devel-5.7.44|mysql-community-devel-8.0.41"; then
            echo "$MYSQL_COMMUNITY_DEVEL"
        fi
    '
    echo

    echo $servidor2

    ssh -qt "$servidor2" '
        MYSQL_VERSION=$(mysql -V)
        if echo "$MYSQL_VERSION" | egrep -q -v "5.7.44|8.0.41"; then
            echo "$MYSQL_VERSION"
        fi
        MYSQL_DEVEL=$(rpm -q MySQL-devel 2>&1)
        if echo "$MYSQL_DEVEL" | grep -q -v "is not installed"; then
            echo "$MYSQL_DEVEL"
        fi
        MYSQL_COMMUNITY_DEVEL=$(rpm -q mysql-community-devel 2>&1)
        if echo "$MYSQL_COMMUNITY_DEVEL" | egrep -q -v "mysql-community-devel-5.7.44|mysql-community-devel-8.0.41"; then
            echo "$MYSQL_COMMUNITY_DEVEL"
        fi
    '
    echo
done
