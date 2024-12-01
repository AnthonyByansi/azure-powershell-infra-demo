#!/bin/bash

# Define the root directory
ROOT_DIR="azure-powershell-infra-demo"

# Create the directory structure
mkdir -p $ROOT_DIR/{scripts,templates,diagrams,docs}

# Create placeholder files
touch $ROOT_DIR/README.md
touch $ROOT_DIR/.gitignore

# Scripts
for script in \
  "01-create-resource-group.ps1" \
  "02-setup-networking.ps1" \
  "03-deploy-virtual-machines.ps1" \
  "04-configure-storage.ps1" \
  "05-deploy-sql-database.ps1" \
  "06-setup-monitoring.ps1" \
  "07-cleanup-resources.ps1"
do
  touch $ROOT_DIR/scripts/$script
done

# Templates
touch $ROOT_DIR/templates/vm-parameters.json
touch $ROOT_DIR/templates/sql-database-parameters.json

# Diagrams
touch $ROOT_DIR/diagrams/infrastructure-diagram.png

# Docs
touch $ROOT_DIR/docs/setup-instructions.md
touch $ROOT_DIR/docs/troubleshooting.md

# Print success message
echo "Directory structure and files for '$ROOT_DIR' created successfully."
