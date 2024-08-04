#!/bin/bash
docker rm -f metrics && docker rmi -f metrics &&  docker build --tag 'metrics' . && docker run -t -d --name=metrics metrics && docker wait metrics && docker cp metrics:/tmp/zips ./
aws s3 sync zips s3://inmoment.codestore
terraform -chdir=./terraform apply -auto-approve