# Problem: K8s Image Pull Error due to disk Pressure


## Problem Statement

When pulling images of large size, temporary size burst happens which requires 2-3xtimes image size to be available in /var to pull the image successfully, if there is no enough space, then image pull fails with reason: node is low on resources ephemeral storage:no space left on this device

## Related Context

When a image is being pulled,Kubernetes scheduler assigns a node, kubelet in that worker node checks with containerd (container run time process), whether this image is already pulled or not, if not containerd will start pulling images and stores all the image related artifacts in /var/lib/containerd (Default Location)

## Why this happens

- Many Organizations use approved AMI's (which passes multiple security checks) created using Workflows(Github Actions etc...) and store in a single aws account and share it to project aws accounts
- Fixed partioning (in our case /var has only 10G space) in AMI
- When pulling images of large size(say >=5GB), temporary size burst requires 2-3Xtimes of image size(>10G), image is not pulled successfully

## Why this matters

- If image is not pulled, pod will not run then app cannot be accessed resulting in outages.

## Observed Constraints

- Shared AMI with no access to image build config so /var can only be 10G
- Containerd defaults to /var/lib/containerd

## Desgin Considerations

- Nodegroups are created via TF and we can control the size of EBS Root Block device

## Approach (One Possible direction)

- Relocate containerd default storage from /var/lib/containerd to root ebs (/mnt/containerd)

## Trade-Offs

- Overtime /mnt/containerd grows and causes risk of disk pressure.
- This script only relocates containerd not performs any cleanup and free disk space

## Additional Considerations

- Kubelet has a Feature `ImageGC - Garbage Collection`, upon specific threshold, kubelet automatically removes the old/unused images in least accessed order.(ImageGCHigh Threshold - 85%, ImageGCLowThreshold - 80%)

- Occassionally run `crictl rmi --prune` to immediately remove unused images

- If images are stored in private registires e.g. ECR - perform nodegroup deletion and recreation to free up space.