https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

----------------After Upgradation File ---------------------
Cheack dependance after upgradation :  ----
--k8s_post_upgrade_check.sh
--chmod +x k8s_post_upgrade_check.sh  ------->Make executable
--./k8s_post_upgrade_check.sh



-------------------- To Run Updagration File to cheack list -----------------
Linux 
---- to download : Install yq (YAML parser)
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq
yq --version

----------Create Runner Script-------
run-checks.sh

#!/bin/bash

FILE="k8s-upgrade-dependency-checklist.yaml"

echo "Starting Kubernetes Upgrade Dependency Checks..."
echo "================================================"

yq eval '
  .dependencies[]?.check[] ,
  .post_upgrade_validation[]?.check[]
' $FILE | while read -r cmd
do
    echo ""
    echo "Running: $cmd"
    echo "------------------------------------------------"
    eval "$cmd"
    echo ""
done


--------------------chmod +x run-checks.sh------------------


./run-checks.sh

./run-checks.sh > upgrade-report.txt

--------------------------------------------
Ensure these tools are installed:

kubectl
Helm
yq
etcdctl (if using external ETCD)

--------------------------------------
Recommended Production Flow
Run checks on staging cluster
Fix deprecated APIs
Take ETCD backup
Upgrade control plane
Upgrade worker nodes
Run post-upgrade validation
Monitor workloads for 24 hours
