echo "[TASK 1] => Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=172.42.42.100 --apiserver-cert-extra-sans=172.42.42.100  --pod-network-cidr=10.244.0.0/16 >> /root/kubeinit.log

# Copy Kube admin config
echo "[TASK 2] => Copy kube admin config to Vagrant user .kube directory"
mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# install Calico pod network addon (enable pod to pod communication)
echo "[TASK 3] => Deploy Calico network"
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
kubeadm token create --print-join-command >> /etc/kubeadm_join_cmd.sh
chmod +x /etc/kubeadm_join_cmd.sh