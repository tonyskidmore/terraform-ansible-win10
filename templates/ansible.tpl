#!/bin/bash

source /etc/os-release

if [[ "$ID" == "ubuntu" ]]
then
  apt update
  apt -y upgrade
  apt install -y python3-pip
elif [[ "$ID" == "rhel" ]]
then
  dnf -y install git
  dnf -y update
else
  echo "Failed to determine OS" > /tmp/cloud-init.log
fi



python3 -m pip install --upgrade pip
python3 -m pip install --upgrade setuptools
python3 -m pip install pywinrm>=0.3.0
python3 -m pip install ansible==4.8.0
ansible-galaxy collection install ansible.windows

cat > /home/${ansible_user}/ansible.cfg <<EOF
[defaults]
inventory = ./inventory
deprecation_warnings = false
callback_whitelist = ansible.posix.profile_tasks
EOF

cat > /home/${ansible_user}/inventory <<EOF
[win]
${win_vm_ip}

[win:vars]
ansible_user=${ansible_user}
ansible_password=${ansible_password}
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
EOF

cat > /home/${ansible_user}/playbook.yml <<EOF
---

- name: Windows playbook
  hosts: win

  pre_tasks:

    - name: Get ansible nodename
      debug:
        var: ansible_nodename

  tasks:

    - name: Run ansible-role-windev role
      include_role:
        name: ansible-role-windev

EOF

mkdir -p /home/${ansible_user}/roles/ansible-role-windev
git clone ${windev_ansible_role_repo} /home/${ansible_user}/roles/ansible-role-windev

mkdir -p /home/${ansible_user}/win_files
echo ${private_key_pem} > /home/${ansible_user}/win_files/id_rsa

chown -R ${ansible_user}:${ansible_user} /home/${ansible_user}/*
