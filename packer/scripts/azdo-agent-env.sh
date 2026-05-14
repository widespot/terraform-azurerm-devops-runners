#!/usr/bin/env bash
set -euo pipefail

# Azure DevOps VMSS agents read VSTS_AGENT_INPUT_* environment variables
# during unattended agent configuration. Keep secrets out of the image.
cat <<'ENV' | sudo tee /etc/profile.d/azdo-agent-env.sh >/dev/null
export VSTS_AGENT_INPUT_WORK=/agent/_work
ENV

sudo mkdir -p /agent/_work
sudo chmod 0777 /agent /agent/_work
