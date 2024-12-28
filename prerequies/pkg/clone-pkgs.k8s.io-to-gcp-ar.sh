sudo rm -rf /var/spool/apt-mirror/mirror/pkgs.k8s.io
sudo apt-mirror /home/matgou/workspace/cka/mycluster/prerequies/pkg/apt-configuration

find /var/spool/apt-mirror/mirror/pkgs.k8s.io/core:/stable:/*/deb/amd64 -name "*deb" | while read file; do  gcloud artifacts apt upload kube-apt-bookworm --location=europe-west9 --source=$file; done;
