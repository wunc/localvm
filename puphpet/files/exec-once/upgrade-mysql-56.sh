#echo '--> Attempting aptitude upgrade.'
#apt-get update
#DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
#echo '--> Aptitude upgrade finished.'

echo '--> Attempting to upgrade MySQL to v5.6.'
debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password password 123'
debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password_again password 123'
apt-get -y install mysql-server-5.6 mysql-client-5.6 mysql-client-core-5.6
echo '--> Upgrade to MySQL v5.6 finished.'

echo '--> Attempting to remove unused or unneeded packages.'
apt-get -y autoremove
echo '--> Unused or unneeded packages removed.'

echo '--> Attempting to update MySQL time zone support.'
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -p123 mysql
echo '--> MySQL time zone support update finished.'

## Optionally, import a database dump. 
# echo '--> Attempting to import MySQL database dump.'
# mysql -u root -pYOUR_PASSWORD YOUR_DATABASE_NAME </var/www/PROJECT/schema.sql
# echo '--> MySQL import finished.'