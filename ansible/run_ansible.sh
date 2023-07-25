#!/bin/bash
# to run ansible from another machine ssh default to current user
ansible-playbook jnano.yaml -i hosts.yaml --ask-pass --ask-become-pass --extra-vars "gmail_app_password=raoxqwozugaxorma"
# choose or skip some tasks by tags
#ansible-playbook jnano.yaml -i hosts.yaml --ask-pass --ask-become-pass --tags install,enable
#ansible-playbook jnano.yaml -i hosts.yaml --ask-pass --ask-become-pass --skip-tags mount,apt,build,netplan,nginx,sql3

# For NFS set-up NEED TO:
# creating id_rsa password for ssh instantly connection 
# ssh-keygen 
# installing on remote orangepi after this ssh andre@orangepi doesnt request password
# ssh-copy-id -i ~/.ssh/id_rsa.pub andre@orangepi 
