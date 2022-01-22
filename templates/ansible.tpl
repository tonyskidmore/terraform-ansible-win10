#!/bin/bash

source /etc/os-release

# perform system and any python3 required updates
if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]]
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

# ansible installation
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade setuptools
python3 -m pip install pywinrm>=0.3.0
python3 -m pip install ansible==4.8.0
ansible-galaxy collection install ansible.windows

# prepare ansible configuration file
cat > /home/${ansible_user}/ansible.cfg <<EOF
[defaults]
inventory = ./inventory
deprecation_warnings = false
callback_whitelist = ansible.posix.profile_tasks
EOF

# prepare static inventory to connect to windows
cat > /home/${ansible_user}/inventory <<EOF
[win]
${win_vm_ip}

[win:vars]
ansible_user=${ansible_user}
ansible_password=${ansible_password}
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
EOF

# create the default windows development playbook
cat > /home/${ansible_user}/win_dev.yml <<EOF
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

# setup ansible roles
mkdir -p /home/${ansible_user}/roles/ansible-role-windev
git clone ${windev_ansible_role_repo} /home/${ansible_user}/roles/ansible-role-windev

# files for WSL ansible deployment
mkdir -p /home/${ansible_user}/win_files
echo ${private_key_pem} > /home/${ansible_user}/win_files/id_rsa

ip=$(hostname -I)

cat > /home/${ansible_user}/win_files/inventory <<EOF
[linux]
$ip

[linux:vars]
ansible_user=${ansible_user}
ansible_ssh_extra_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

EOF

cat > /home/${ansible_user}/win_files/ansible.cfg <<EOF
[defaults]
inventory = ./inventory
deprecation_warnings = false
callback_whitelist = ansible.posix.profile_tasks

EOF

cat > /home/${ansible_user}/win_files/linux.yml <<EOF
---

- name: Linux playbook
  hosts: linux

  pre_tasks:

    - name: Get ansible role content
      ansible.builtin.command: "ansible-galaxy install -r requirements.yml --roles-path {{ playbook_dir }}/roles"

  tasks:

    - name: Run ansible-role-apache
      include_role:
        name: ansible-role-apache

EOF

cat > /home/${ansible_user}/win_files/requirements.yml <<EOF
- src: https://github.com/geerlingguy/ansible-role-apache
  version: master
  name: ansible-role-apache

EOF

# update Linux user home permisions
chown -R ${ansible_user}:${ansible_user} /home/${ansible_user}/*
