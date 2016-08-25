#!/bin/bash

hacking_dir=$(readlink -fn $(dirname "$BASH_SOURCE"))
export ANSIBLE_CONFIG=$hacking_dir/ansible/ansible.cfg
export ANSIBLE_INVENTORY=$hacking_dir/inventory

