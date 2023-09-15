#!/bin/bash
# to run ansible from another machine ssh default to current user
ansible-playbook orangepi5.yaml -i hosts.yaml --ask-pass --ask-become-pass --extra-vars "gmail_app_password=raoxqwozugaxorma"
# choose or skip some tasks by tags
#ansible-playbook orangepi5.yaml -i hosts.yaml --ask-pass --ask-become-pass --tags install,enable
#ansible-playbook orangepi5.yaml -i hosts.yaml --ask-pass --ask-become-pass --skip-tags mount,apt,build,netplan,nginx,sql3
