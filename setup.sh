#!/bin/bash
# make this script executable with: chmod +x setup.sh
# run it with: ./setup.sh

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${RED}Applying Istio initialization configuration...${NC}"
kubectl apply -f istio-init.yaml
echo -e "${GREEN}Done${NC}"

echo -e "${RED}Enabling Istio injection in the default namespace...${NC}"
kubectl label namespace default istio-injection=enabled > /dev/null
echo -e "${GREEN}Done${NC}"

# Wait until all pods in the istio-system namespace are running
echo -e "${RED}Starting pods in the istio-system namespace...${NC}"
while true; do
    # Get a list of all pods in the istio-system namespace
    pods=$(kubectl get pods -n istio-system -o jsonpath='{.items[*].metadata.name}')

    # Check the status of each pod
    all_running=true
    for pod in $pods; do
        status=$(kubectl get pods -n istio-system "$pod" -o jsonpath='{.status.phase}')
        if [[ "$status" != "Running" ]]; then
            all_running=false
            break
        fi
    done

    # If all pods are running, exit the loop
    if [[ "$all_running" == "true" ]]; then
        break
    fi

    sleep 1
done
echo -e "${GREEN}Done${NC}"

# Define the spin states
spin[0]="-"
spin[1]="\\"
spin[2]="|"
spin[3]="/"

# Wait until Kiali is running
echo -ne "${RED}Kiali will start in about 1 minute... ${NC}"

# Hide the cursor
echo -ne "\033[?25l"

# Wait until the Kiali pod's health check has passed
while true; do

    # Start the spinner
    for i in "${spin[@]}"
      do
        # Set the text color to red
        echo -ne "${RED}"
        # Output the spinner character
        echo -ne "\b$i"
        # Reset the text color to the default
        echo -ne "${NC}"
        sleep 0.1
      done

    # Check the status of the Kiali pod's health check
    status=$(kubectl -n istio-system get pods | grep kiali | awk '{print $2}' | grep '^1')

    # If the Kiali pod's health check has passed, break out of the loop
    if [ "$status" == "1/1" ]; then
    # Overwrite the spinner characters with spaces
        echo -ne "\b"
        break
    fi    

done

# Show the cursor
echo -e "\033[?25h"
echo -e "${GREEN}Done${NC}"

echo -e "${RED}Forwarding the Kiali service port to localhost...${NC}"
kubectl port-forward -n istio-system svc/kiali 8088:20001 &
echo -e "${GREEN}Done${NC}"

echo -e "${RED}Opening the Kiali console in the default browser...${NC}"
open http://localhost:8088/kiali/console/overview?duration=60&refresh=15000
echo -e "${GREEN}Done${NC}"
