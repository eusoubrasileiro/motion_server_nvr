#!/bin/bash
# to run ansible from another machine ssh default to current user
ansible-playbook jnano.yaml -i hosts.yaml --ask-pass --ask-become-pass
# choose some tasks by tags
#ansible-playbook jnano.yaml -i hosts.yaml --ask-pass --ask-become-pass --tags install,enable