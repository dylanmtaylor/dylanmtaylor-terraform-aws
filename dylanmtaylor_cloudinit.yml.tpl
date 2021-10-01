#cloud-config

runcmd:
 - sudo apt update
 - sudo apt -y install git ansible wget curl
 - sudo ansible-galaxy collection install ansible.posix
 - wget https://raw.githubusercontent.com/dylanmtaylor/Swap/master/swap.sh -O swap
 - sudo sh swap 2G /swap
 - git clone https://gitlab.com/dylanmtaylor/dylanmtaylor-ansible /tmp/ansible
 - mkdir -p /etc/ansible
 - echo '[servers]\nlocalhost' | sudo tee /etc/ansible/hosts # uses sh's echo not bash, -e not needed
 - sudo ansible-playbook --connection=local /tmp/ansible/playbook.yml
