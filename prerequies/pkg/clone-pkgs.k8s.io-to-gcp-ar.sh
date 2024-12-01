apt-mirror apt-configuration
find /var/spool/apt-mirror/mirror/pkgs.k8s.io/core: -name "*deb" | while read file; do  gcloud artifacts apt upload kube-apt-bookworm --location=europe-west9 --source=$file; done;
