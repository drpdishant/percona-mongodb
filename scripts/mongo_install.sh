#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
# https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel8-7.0.15.tgz
# Variables
MONGODB_VERSION="7.0.15"
MONGODB_BASE_URL="https://fastdl.mongodb.org/linux"
MONGODB_TAR="mongodb-linux-x86_64-rhel8-${MONGODB_VERSION}.tgz"
INSTALL_DIR="/opt/mongodb"
DATA_DIR="/MongoData"
LOG_DIR="/MongoLogs"
REPLICA_SET_NAME="AcquiUAT"
SSM_PARAMETER_PREFIX="/acqui/mongodb/node"  # Base path for SSM parameters
NODE_COUNT=3  # Total number of MongoDB nodes0
MONGODB_PORT="27072"

# Function to install MongoDB from tarball
install_mongodb_tar() {
    echo "Installing MongoDB from tarball..."
    sudo yum install -y libcurl openssl xz-libs jq
    wget -q "${MONGODB_BASE_URL}/${MONGODB_TAR}" -O /tmp/${MONGODB_TAR}
    mkdir -p ${INSTALL_DIR}
    tar -xzf /tmp/${MONGODB_TAR} -C ${INSTALL_DIR} --strip-components=1
    rm /tmp/${MONGODB_TAR}
    echo "MongoDB extracted to ${INSTALL_DIR}."

    # Add MongoDB binary to PATH
    echo "export PATH=${INSTALL_DIR}/bin:${PATH}" | sudo tee -a /etc/environment
    export PATH=${INSTALL_DIR}/bin:$PATH

    # Create necessary directories
    sudo mkdir -p ${DATA_DIR} ${LOG_DIR}
    sudo chown -R $(whoami):$(whoami) ${DATA_DIR} ${LOG_DIR}
    echo "Directories ${DATA_DIR} and ${LOG_DIR} created."
}

# Function to configure and start MongoDB
start_mongodb() {
    echo "Starting MongoDB instance..."
    mongod --dbpath ${DATA_DIR} --logpath ${LOG_DIR}/mongodb.log --fork --replSet ${REPLICA_SET_NAME} --bind_ip_all --port ${MONGODB_PORT}
    echo "MongoDB instance started with replica set name '${REPLICA_SET_NAME}'."
}

# Function to get IPs for all nodes from AWS SSM
get_ips_from_ssm() {
    echo "Fetching replica set IPs from SSM Parameter Store..."
    export AWS_DEFAULT_REGION="ap-south-2"
    ip_array=()
    for ((i = 0; i < NODE_COUNT; i++)); do
        ip=$(aws ssm get-parameter --name "${SSM_PARAMETER_PREFIX}/${i}/ip" --query "Parameter.Value" --output text)
        ip_array+=("$ip:$MONGODB_PORT")
    done
    echo "Fetched IPs: ${ip_array[@]}"
}


# Function to configure replica set
configure_replica_set() {
    echo "Configuring MongoDB replica set..."
    members=""
    for i in "${!ip_array[@]}"; do
        members+="{\"_id\": $i, \"host\": \"${ip_array[$i]}\"},"
    done
    members=${members%,}

    mongosh  --port ${MONGODB_PORT} --eval "
    rs.initiate({
        _id: '${REPLICA_SET_NAME}',
        members: [
            ${members}
        ]
    });
    printjson(rs.status());
    "
    echo "Replica set configured."
}



# Write Mongodb Node Running State to Parameter Store
write_mongodb_state() {
    echo "Writing Mongodb Node Running State to Parameter Store"
    export AWS_DEFAULT_REGION="ap-south-2"
    ip_array=()
    for ((i = 0; i < NODE_COUNT; i++)); do
        ip=$(aws ssm put-parameter --name "${SSM_PARAMETER_PREFIX}/${i}/running" --value "true")
        ip_array+=("$ip:$MONGODB_PORT")
    done
    echo "Fetched IPs: ${ip_array[@]}"
}

# Main script execution
install_mongodb_tar
start_mongodb
get_ips_from_ssm
sleep 60
configure_replica_set
write_mongodb_state
