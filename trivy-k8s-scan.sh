#!/bin/bash

echo $imageName

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy -q image --exit-code 0 --severity LOW,MEDUIM,HIGHT --light $imageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy -q image --exit-code 1 --severity CRITICAL --light $imageName 

    #trivy scan result processing
    exit_code=$?
    echo "Exit Code : $exit_code"

    # Check scan results
    if [[ "${exit_code}" == 1 ]]; then
        echo "Image scanning failed. Vulnerabilities found"
        exit 1;
    else
        echo "Image scanning passed. No Vulnerabilities found"
    fi;