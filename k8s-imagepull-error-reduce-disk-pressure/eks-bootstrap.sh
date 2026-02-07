MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex

# Stop services
systemctl stop kubelet || true
systemctl stop containerd || true

# Create new containerd root on root EBS
mkdir -p /mnt/containerd
chmod 755 /mnt/containerd

# Create containerd override
mkdir -p /etc/containerd/config.d
cat <<EOF >/etc/containerd/config.d/99-root.toml  #During run time config.toml uses imports from config.d and hence root will be updated.
root = "/mnt/containerd"
EOF

## Run bootstrap --> takes care of starting containerd and kubelet no need to start explicitly
B64_CLUSTER_CA=${cluster_certificate_authority}
API_SERVER_URL=${cluster_api_url}
/etc/eks/bootstrap.sh ${cluster_name} --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=${nodegroup_ami},eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=${node_group_name}' --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL
--//--