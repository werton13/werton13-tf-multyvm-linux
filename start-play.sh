#!/bin/bash
apt-get update
apt-get install -y ansible
# clone Git repo from URL 'var.AnsPlayBookURL'
echo "AnsPlayBookURL:${AnsPlayBookURL}" >> /var/log/terra.log
git clone ${AnsPlayBookURL}
#CD into repo folder 'var.AnsPlayBookFolder'
echo "AnsPlayBookFolder:${AnsPlayBookFolder}" >> /var/log/terra.log
cd ./${AnsPlayBookFolder}

#Run Ansible playbook with exra vars -'ansible_user', 'ansible_sudo_pass'
ansible-playbook ${AnsPlayBookName} -e "ansible_user=${ansible_user} ansible_sudo_pass=${ansible_sudo_pass} ssh_port=${ssh_port}"