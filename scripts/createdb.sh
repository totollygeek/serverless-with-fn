#!/bin/sh
exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" < /scripts/initdb.sql