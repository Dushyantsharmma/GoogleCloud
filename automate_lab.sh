#!/bin/bash

# Create VPC network and firewall rules
gcloud compute networks create privatenet --subnet-mode custom
gcloud compute networks subnets create privatenet-us --network privatenet --range 10.130.0.0/20
gcloud compute firewall-rules create privatenet-allow-ssh --network privatenet --source-ranges 35.235.240.0/20 --allow tcp:22

# Create VM instance with no external IP address
gcloud compute instances create vm-internal --zone us-central1-c --machine-type n1-standard-1 --image-family debian-11 --image-project debian-cloud --subnet privatenet-us --no-address

# Enable Private Google Access
gcloud compute networks subnets update privatenet-us --region us-central1 --enable-private-ip-google-access

# Create a Cloud NAT gateway
gcloud compute routers create nat-router --region us-central1
gcloud compute routers nats create nat-config --router-region us-central1 --router nat-router --nat-all-subnet-ip-ranges --auto-allocate-nat-external-ips

# Test VM instance update
gcloud compute ssh vm-internal --zone us-central1-c --tunnel-through-iap << EOF
sudo apt-get update
exit
EOF

# Verify Cloud NAT configuration
gcloud compute ssh vm-internal --zone us-central1-c --tunnel-through-iap << EOF
sudo apt-get update
exit
EOF

# Enable Cloud NAT logging
gcloud compute routers nats update nat-config --router-region us-central1 --router nat-router --enable-logging
