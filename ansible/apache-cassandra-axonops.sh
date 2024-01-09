source ../.aws/config
export ANSIBLE_HOST_KEY_CHECKING=false
cp -r group_vars/tag_ClusterName_axonops group_vars/tag_ClusterName_$TF_VAR_CASSANDRA_CLUSTER_NAME
ansible-playbook -i inventory/axonops/aws_ec2.yml apache-cassandra-axonops.yml --diff