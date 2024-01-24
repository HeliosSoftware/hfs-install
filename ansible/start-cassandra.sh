source ../.aws/config
export ANSIBLE_HOST_KEY_CHECKING=false
ansible-playbook -i inventory/axonops/aws_ec2.yml start-cassandra.yml --diff
