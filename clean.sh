#!/bin/bash
# make this script executable with: chmod +x clean.sh
# run it with: ./clean.sh

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Enable the errexit option to exit the script immediately if a command returns a non-zero exit status
set -e

echo -e "${RED}Uninstalling Istio...${NC}"
kubectl delete -f istio-init.yaml --ignore-not-found=true
echo -e "${GREEN}Done.${NC}"

echo -e "${RED}Removing Istio injection label from the default namespace...${NC}"
kubectl label namespace default istio-injection- --overwrite
echo -e "${GREEN}Done.${NC}"
