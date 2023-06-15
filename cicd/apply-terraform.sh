#!/bin/bash

# fail on any error
set -eu

# go back to the previous directory
cd .. 

# initialize terraforms
 terraform init

# plan terraform
#terraform plan
# # apply terraform
terraform  destroy -auto-approve -lock=false

# destroy terraform
# terraform destroy -auto-approve
