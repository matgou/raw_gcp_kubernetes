kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml
cat >calico-custom-resources.yaml <<EOF
apiVersion: operator.tigera.io/v1
kind: ImageSet
metadata:
  name: calico-gcp
spec:
  images:
    - image: 'mirror.gcr.io/calico/apiserver:v3.25.0'
      digest: 'sha256:9819c1b569e60eec4dbab82c1b41cee80fe8af282b25ba2c174b2a00ae555af6'
    - image: 'mirror.gcr.io/calico/cni:v3.25.0'
      digest: sha256:a38d53cb8688944eafede2f0eadc478b1b403cefeff7953da57fe9cd2d65e977
    - image: 'mirror.gcr.io/calico/kube-controllers:v3.25.0'
      digest: 'sha256:c45af3a9692d87a527451cf544557138fedf86f92b6e39bf2003e2fdb848dce3'
    - image: 'mirror.gcr.io/calico/node:v3.25.0'
      digest: 'sha256:a85123d1882832af6c45b5e289c6bb99820646cb7d4f6006f98095168808b1e6'
    - image: 'mirror.gcr.io/calico/typha:v3.25.0'
      digest: 'sha256:f7e0557e03f422c8ba5fcf64ef0fac054ee99935b5d101a0a50b5e9b65f6a5c5'
    - image: 'mirror.gcr.io/calico/pod2daemon-flexvol:v3.25.0'
      digest: 'sha256:01ddd57d428787b3ac689daa685660defe4bd7810069544bd43a9103a7b0a789'
    - image: 'calico/node-windows'
      digest: 'sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
    - image: 'europe-west9-docker.pkg.dev/sandbox-mgoulin/kube-docker-quay-repo-proxy/tigera/operator:v1.36.2'
      digest: 'sha256:fc9ea45f2475fd99db1b36d2ff180a50017b1a5ea0e82a171c6b439b3a620764'
    - image: 'europe-west9-docker.pkg.dev/sandbox-mgoulin/kube-docker-quay-repo-proxy/tigera/key-cert-provisioner:v1.1.6'
      digest: 'sha256:fa3613626fcec0d8952eed4126fbb072ca62b4f4fecc403a5fe5b0decd8fc17b'

---
# This section includes base Calico installation configuration.
# For more information, see: https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    ipPools:
    - name: default-ipv4-ippool
      blockSize: 26
      cidr: 100.64.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()

---

# This section configures the Calico API server.
# For more information, see: https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
EOF

kubectl create -f calico-custom-resources.yaml
