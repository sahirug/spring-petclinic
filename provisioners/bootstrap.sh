
# Update hosts file
echo "[TASK 1] => Update /etc/hosts file"
cat >>/etc/hosts<<EOF
172.42.42.100 kmaster.example.com kmaster
172.42.42.101 kworker1.example.com kworker1
172.42.42.102 kworker2.example.com kworker2
EOF

# Install docker from Docker-ce repository
echo "[TASK 2] => Install docker container engine"
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# let vagrant user access docker
echo "[TASK 3] => Adding vagrant user to docker group"
usermod -aG docker vagrant

# install kubeadm
echo "[TASK 4] => Installing kubeadm"
apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main  
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# turning off swap per kubelet requirement
echo "[TASK 5] => Turning off swap"
swapoff -a

# keep swap off after reboot
echo "[TASK 6] => Turning off swap after reboot"
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Enable ssh password authentication
echo "[TASK 7] => Enable ssh password authentication"
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo service sshd restart

# Set Root password
echo "[TASK 8] => Set root password"
echo "kubeadmin" | passwd --stdin root >/dev/null 2>&1

# Update vagrant user's bashrc file
echo "export TERM=xterm" >> /etc/bashrc