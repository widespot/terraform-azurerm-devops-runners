#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Enable access to KVM
# We want to add the default user to the kvm group.
# Since the user is created at instantiation time, we use a cloud-init per-instance script.

# Ensure the cloud-init scripts directory exists
sudo mkdir -p /var/lib/cloud/scripts/per-instance/

# Create the provisioning script
cat <<EOF | sudo tee /var/lib/cloud/scripts/per-instance/add-default-user-to-kvm.sh
#!/usr/bin/env bash
# This script runs during the first boot of the VM instance

# Get the first user with UID 1000 (usually the default admin user in Azure)
DEFAULT_USER=\$(id -un 1000 2>/dev/null || true)

if [ -n "\$DEFAULT_USER" ]; then
    echo "Adding \$DEFAULT_USER to kvm group"
    usermod -aG kvm "\$DEFAULT_USER"
fi
EOF

# Make it executable
sudo chmod +x /var/lib/cloud/scripts/per-instance/add-default-user-to-kvm.sh

