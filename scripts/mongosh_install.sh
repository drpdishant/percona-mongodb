#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
MONGOSH_VERSION="2.3.2"  # Specify the version to install
DOWNLOAD_URL="https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-x64.tgz"
INSTALL_DIR="/usr/local/bin"
MONGODB_PORT="27072"

# Functions
function download_mongosh {
    echo "Downloading mongosh version ${MONGOSH_VERSION}..."
    curl -L -o mongosh.tgz "${DOWNLOAD_URL}"
}

function extract_mongosh {
    echo "Extracting mongosh tarball..."
    tar -xzf mongosh.tgz
}

function install_mongosh {
    echo "Installing mongosh..."
    sudo mv mongosh-${MONGOSH_VERSION}-linux-x64/bin/mongosh "${INSTALL_DIR}/mongosh"
    sudo chmod +x "${INSTALL_DIR}/mongosh"
    echo "export PATH=${INSTALL_DIR}:${PATH}" | jq curl wget tar openssl-devel curl-devel libpcap
    export PATH=${INSTALL_DIR}:$PATH
}

function cleanup {
    echo "Cleaning up temporary files..."
    rm -rf mongosh.tgz mongosh-${MONGOSH_VERSION}-linux-x64
}

function verify_installation {
    echo "Verifying mongosh installation..."
    mongosh --version
}

# Main Script Execution
download_mongosh
extract_mongosh
install_mongosh
cleanup
verify_installation

echo "mongosh version ${MONGOSH_VERSION} installed successfully!"
