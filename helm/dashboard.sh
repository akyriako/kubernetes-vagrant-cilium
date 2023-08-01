#!/bin/bash

echo ">>> INSTALL HELM DASHBOARD"

helm repo add komodorio https://helm-charts.komodor.io
helm repo update
helm upgrade --install dashboard komodorio/helm-dashboard --namespace helm-dashboard --create-namespace