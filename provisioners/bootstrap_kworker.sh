echo "[TASK 1] => Join node to Kubernetes Cluster"
sudo apt install -y sshpass >/dev/null 2>&1
sudo sshpass -p "vagrant" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@kmaster.example.com:/etc/kubeadm_join_cmd.sh /etc/kubeadm_join_cmd.sh 2>/dev/null
bash /etc/kubeadm_join_cmd.sh >/dev/null 2>&1