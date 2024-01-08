source ../.aws/config
ansible-playbook -i inventory/axonops/aws_ec2.yml cassandra-common.yml --diff
ansible-playbook -i inventory/axonops/aws_ec2.yml apache-cassandra-axonops.yml --diff