#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

cloud-init -d -f /var/lib/capi/bootstrap.yml init

tail -f /dev/null
cloud-init -d -f /var/lib/capi/bootstrap.yml modules
cloud-init -d -f /var/lib/capi/bootstrap.yml modules --mode final

# /usr/local/bin/kubeadm-bootstrap-script

tail -f /dev/null