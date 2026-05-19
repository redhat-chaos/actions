#!/bin/bash

set -e  # Exit on error

echo "=========================================="
echo "Installing KubeVirt..."
echo "=========================================="

# Get the latest KubeVirt version
export KUBEVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)
echo "Latest KubeVirt version: $KUBEVIRT_VERSION"

# Install KubeVirt operator
echo "Installing KubeVirt operator..."
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml

# Install KubeVirt custom resource
echo "Installing KubeVirt CR..."
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-cr.yaml

# Wait for KubeVirt to be ready
echo "Waiting for KubeVirt to be ready..."
kubectl wait --for=condition=Available --timeout=300s -n kubevirt kubevirt kubevirt

echo "=========================================="
echo "Enabling software emulation mode..."
echo "=========================================="

# Enable software emulation (needed for macOS and systems without KVM)
kubectl -n kubevirt patch kubevirt kubevirt --type=merge --patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'

# Wait a bit for the patch to apply
sleep 10

echo "=========================================="
echo "Installing virtctl CLI tool..."
echo "=========================================="

# Download virtctl (KubeVirt CLI)
VIRTCTL_VERSION=$KUBEVIRT_VERSION
curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${VIRTCTL_VERSION}/virtctl-${VIRTCTL_VERSION}-darwin-amd64
chmod +x virtctl
sudo mv virtctl /usr/local/bin/

echo "=========================================="
echo "Creating a test VM..."
echo "=========================================="

# Create a simple test VM
cat <<EOF | kubectl apply -f -
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: testvm
spec:
  running: true
  template:
    metadata:
      labels:
        kubevirt.io/domain: testvm
    spec:
      domain:
        devices:
          disks:
          - name: containerdisk
            disk:
              bus: virtio
          - name: cloudinitdisk
            disk:
              bus: virtio
        resources:
          requests:
            memory: 1024M
      volumes:
      - name: containerdisk
        containerDisk:
          image: quay.io/kubevirt/cirros-container-disk-demo
      - name: cloudinitdisk
        cloudInitNoCloud:
          userDataBase64: SGkuXG4=
EOF

echo "=========================================="
echo "Waiting for VM to be ready..."
echo "=========================================="

# Wait for VM to be ready
kubectl wait --for=condition=Ready --timeout=300s vmi/testvm

echo "=========================================="
echo "KubeVirt Setup Complete!"
echo "=========================================="

echo ""
echo "Useful commands:"
echo "  - List VMs: kubectl get vms"
echo "  - List VM instances: kubectl get vmis"
echo "  - Get VM status: virtctl status testvm"
echo "  - Console access: virtctl console testvm"
echo "  - SSH to VM: virtctl ssh cirros@testvm (password: gocubsgo)"
echo "  - Stop VM: virtctl stop testvm"
echo "  - Start VM: virtctl start testvm"
echo ""
echo "VM 'testvm' is now running!"
