#!/bin/bash

echo ">>> INIT MASTER NODE"

sudo systemctl enable kubelet

kubeadm init \
  --apiserver-advertise-address=$MASTER_NODE_IP \
  --control-plane-endpoint $MASTER_NODE_IP \
  --skip-phases=addon/kube-proxy \
  --ignore-preflight-errors=NumCPU \

echo ">>> CONFIGURE KUBECTL"

sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

mkdir -p /home/vagrant/.kube
sudo cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown $(id -u):$(id -g) /home/vagrant/.kube/config

sudo chown -R vagrant /home/vagrant/.kube
sudo chgrp -R vagrant /home/vagrant/.kube

sudo cp -i /etc/kubernetes/admin.conf /vagrant/kubeadm/admin.conf

echo ">>> FIX KUBELET NODE IP"
echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$MASTER_NODE_IP\"" | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

echo ">>> DEPLOY CNI > CILIUM"

CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

sudo cilium install
sudo cilium hubble enable
sudo cilium hubble ebable --ui

echo ">>> GET WORKER JOIN COMMAND "

rm -f /vagrant/kubeadm/init-worker.sh
kubeadm token create --print-join-command >> /vagrant/kubeadm/init-worker.sh
