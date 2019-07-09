ENV[ 'VAGRANT_NO_PARALLEL' ] = 'yes'

Vagrant.configure( 2 ) do | config |
  config.vm.provision "shell", path: "provisioners/bootstrap.sh"

  # k8s master node
  config.vm.define "kmaster" do | kmaster |
    kmaster.vm.box = "ubuntu/xenial64"
    kmaster.vm.hostname = "kmaster.example.com"
    kmaster.vm.network "private_network", ip: "172.42.42.100"
    kmaster.vm.provider "virtualbox" do | vb |
      vb.name = "kmaster"
      vb.memory = 2048
      vb.cpus = 2
    end
    kmaster.vm.provision "shell", path: "provisioners/bootstrap_kmaster.sh"
  end  

  # declare the number of nodes in the cluster
  NodeCount = 1

  (1..NodeCount).each do | i |
    config.vm.define "kworker#{i}" do | workernode |
      workernode.vm.box = "ubuntu/xenial64"
      workernode.vm.hostname = "kworker#{i}.example.com"
      workernode.vm.network "private_network", ip: "172.42.42.10#{i}"
      workernode.vm.provider "virtualbox" do | vb |
        vb.name = "kworker#{i}"
        vb.memory = 1024
        vb.cpus = 2
      end
      workernode.vm.provision "shell", path: "provisioners/bootstrap_kworker.sh"
    end
  end 
end  