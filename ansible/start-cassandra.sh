source ../.aws/config
ansible-playbook -i inventory/axonops/aws_ec2.yml start-cassandra.yml --diff
