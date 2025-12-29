sudo usermod -d /MongoData mongodadmin
curl -sL https://downloads.percona.com/downloads/percona-server-mongodb-7.0/percona-server-mongodb-7.0.14-8/binary/tarball/percona-server-mongodb-7.0.14-8-x86_64.jammy.tar.gz -o /tmp/percona-server-mongodb.tar.gz
mkdir -p /MongoData/percona-mongodb

tar -xvzf /tmp/percona-server-mongodb.tar.gz -C ~/percona-mongodb --strip-components=1
mkdir -p /MongoData/data /MongoLogs
chown -R mongoadmin:mongoadmin /MongoData/data /MongoLogs