# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

servers = [
  {
    :name => "kube-master",
    :type => "master",
    :box => "ubuntu/xenial64",
    :version => "20190627.0.0",
    :eth1 => "192.168.205.10",
    :mem => "1024",
    :cpu => "2"
  },
  {
    :name => "kube-node-1",
    :type => "node",
    :box => "ubuntu/xenial64",
    :version => "20190627.0.0",
    :eth1 => "192.168.205.11",
    :mem => "512",
    :cpu => "2"
  },
  # {
  #   :name => "kube-node-2",
  #   :type => "node",
  #   :box => "ubuntu/xenial64",
  #   :version => "20190627.0.0",
  #   :eth1 => "192.168.205.12",
  #   :mem => "1024",
  #   :cpu => "2"
  # }
]

$configureBox = <<-SCRIPT
  export DEBIAN_FRONTEND=noninteractive
  # install docker
  echo "[ ==== INSTALLING DOCKER ==== ]"
  apt-get update
  apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce

  # let vagrant user access docker
  echo "[ ==== ADDING USER TO DOCKER GROUP ==== ]"
  usermod -aG docker vagrant

  # install kubeadm
  echo "[ ==== INSTALLING KUBEADM ==== ]"
  apt-get install -y apt-transport-https curl
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
  deb http://apt.kubernetes.io/ kubernetes-xenial main  
EOF
  apt-get update
  apt-get install -y kubelet kubeadm kubectl
  apt-mark hold kubelet kubeadm kubectl

  # turning off swap per kubelet requirement
  echo "[ ==== TURNING OFF SWAP ==== ]"
  swapoff -a

  # keep swap off after reboot
  echo "[ ==== TURNING OFF SWAP AFTER REBOOT ==== ]"
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

  # ip of this box
  echo "[ ==== GET IP OF BOX ==== ]"
  IP_ADDR=`ifconfig enp0s8 | grep Mask | awk '{print $2}'| cut -f2 -d:`

  # set node-ip
  echo "[ ==== SET IP ==== ]"
  sudo sed -i "/^[^#]*KUBELET_EXTRA_ARGS=/c\KUBELET_EXTRA_ARGS=--node-ip=$IP_ADDR" /etc/default/kubelet
  sudo systemctl restart kubelet
SCRIPT

$configureMaster = <<-SCRIPT
  # ip of this box
  echo "[ ==== GET IP OF BOX ==== ]"
  IP_ADDR=`ifconfig enp0s8 | grep Mask | awk '{print $2}'| cut -f2 -d:`

  # install k8s master
  echo "[ ==== KUBEADM INIT ==== ]"
  HOST_NAME=$(hostname -s)
  kubeadm init --apiserver-advertise-address=$IP_ADDR --apiserver-cert-extra-sans=$IP_ADDR  --node-name $HOST_NAME --pod-network-cidr=192.168.0.0/16

  #copying credentials to regular user - vagrant
  echo "[ ==== COPYING CREDENTIALS ==== ]"
  sudo --user=vagrant mkdir -p /home/vagrant/.kube
  cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
  chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config

  # install Calico pod network addon (enable pod to pod communication)
  echo "[ ==== INSTALLING CALICO ==== ]"
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
  kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
  kubeadm token create --print-join-command >> /etc/kubeadm_join_cmd.sh
  chmod +x /etc/kubeadm_join_cmd.sh
    
  # required for setting up password less ssh between guest VMs
  echo "[ ==== RESTART SSH ==== ]"
  sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
  sudo service sshd restart
SCRIPT

$configureNode = <<-SCRIPT
  echo "[ ==== INSTALL SSHPASS AND COPY BASH SCRIPT FROM MASTER ==== ]"
  apt-get install -y sshpass
    sshpass -p "vagrant" scp -o StrictHostKeyChecking=no vagrant@192.168.205.10:/etc/kubeadm_join_cmd.sh .
    sh ./kubeadm_join_cmd.sh
SCRIPT

Vagrant.configure("2") do |config|

  servers.each do | opts |
  
      config.vm.define opts[:name] do | config |
      
        config.vm.box = opts[:box]
        config.vm.box_version = opts[:version]
        config.vm.hostname = opts[:name]
        config.vm.network :private_network, ip: opts[:eth1]

        config.vm.provider "virtualbox" do | vb |
        
          vb.name = opts[:name]
          vb.customize ["modifyvm", :id, "--memory", opts[:mem]]
          vb.customize ["modifyvm", :id, "--cpus", opts[:cpu]]

        end

        config.vm.provision "shell", inline: $configureBox

        if opts[:type] == "master"
          config.vm.provision "shell", inline: $configureMaster
        else
          config.vm.provision "shell", inline: $configureNode
        end

      end   
  
  end  

end
