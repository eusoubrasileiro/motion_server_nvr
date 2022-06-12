#!/bin/bash
# to run ansible from another machine ssh default to current user
ansible-playbook jnano.yaml -i hosts.yaml --ask-pass --ask-become-pass
# choose or skip some tasks by tags
#ansible-playbook jnano.yaml -i hosts.yaml --ask-pass --ask-become-pass --tags install,enable
#ansible-playbook jnano.yaml -i hosts.yaml --ask-pass --ask-become-pass --skip-tags mount,apt,build,netplan,nginx,sql3