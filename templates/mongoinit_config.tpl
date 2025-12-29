systemLog:
  destination: file
  path: /MongoLogs/mongod.log
  logAppend: true

storage:
  dbPath: /MongoData/data
  journal:
    enabled: true

net:
  port: 27072
  bindIp: 0.0.0.0  # Adjust as needed for remote access

security:
  authorization: disabled

replication:
  replSetName: AcquiUAT