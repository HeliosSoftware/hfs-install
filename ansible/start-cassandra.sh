source ../.aws/config
export ANSIBLE_HOST_KEY_CHECKING=false
export TF_VAR_AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
ansible-playbook -i inventory/axonops/aws_ec2.yml start-cassandra.yml --diff
