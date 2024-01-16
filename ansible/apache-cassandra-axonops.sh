source ../.aws/config
export ANSIBLE_HOST_KEY_CHECKING=false
export TF_VAR_AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
cp -r group_vars/tag_ClusterName_axonops group_vars/tag_ClusterName_$TF_VAR_CASSANDRA_CLUSTER_NAME
ansible-playbook -i inventory/axonops/aws_ec2.yml apache-cassandra-axonops.yml --diff