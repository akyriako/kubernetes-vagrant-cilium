#!/bin/bash

echo ">>> INSTALL METRICS-SERVER"

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

helm upgrade --install --values /vagrant/monitoring/metrics-server/overrides.yaml metrics-server metrics-server/metrics-server --namespace kube-system 

