# Helios FHIR Server Install

This README provides comprehensive instructions for creating a statically defined AWS VPC, Cassandra servers on EC2 instances, and additional infrastructure components using Terraform and Ansible.

There are two high level steps in this automation:

1. Terraform to provision the following:
* AWS VPC networks in us-east-1
* 6 subnets in VPC, public and private, all in us-east-1
* Network routing
* EKS cluster and related configurations
* IAM roles and policies
* Security groups
* Bastion Linux server with a public IP address (also used for NAT gateway)
* Cassandra Linux servers

2. Ansible automation to provision Cassandra cluster on the Linux hosts provisioned in step 1


### Using Bash Shell ###
You must use a bash shell to run the Terraform provisioning commands.

### Manually Creating Key Pairs ###
You must manually create two key pairs in your AWS account named kubectl1-keypair and worker-keypair, both of type RSA. The declaration of these key pairs is in the worker.tf file.


### S3 Backend Bucket ###
Before running Terraform, manually create an S3 backend bucket named helios-terraform-bucket in your AWS account.

### Preparation ###
1. Clone this repository.
2. Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
3. Run `terraform init`
4. Install [make](https://formulae.brew.sh/formula/make)
5. At the root of this repository, manually create the following file.
```
./.aws/config
```
4. Add the following content to ./.aws/config
```
export AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY>
export AWS_DEFAULT_REGION=<AWS_DEFAULT_REGION>
export ANSIBLE_HOST_KEY_CHECKING=false
```
### Setting AWS Credentials ###
In addition to the .aws/config method that is already mentioned in the README, you can also set your AWS access key and secret access key using the following export commands in bash:

* export AWS_ACCESS_KEY_ID=<your_access_key_id>
* export AWS_SECRET_ACCESS_KEY=<your_secret_acc


### Executing Terraform to Provision AWS ###
The Terraform has been configured to provision a VPC network in us-east-1 region, with a CIDR range of `10.0.0.0/16`.

```
Public subnet CIDR range: 10.0.255.0/25
Private subnet CIDR range: 10.0.1.0/24
```

A bastion Linux server is provisioned into the Public subnet range with a public Elastic IP. This is so you can initially SSH to this node. There are other means of accessing Linux servers in AWS, such as the Client VPN service. This PoC setup has been created with a simple setup but you may want to implement this differently.

The configurations for Terraform can be found in ./terraform/variables.tf.  Replace the automation_ssh_pubkey default value to the contents of ~/.ssh/id_rsa.pub or ~/.ssh/id_ed25519.pub

Assuming the terraform binary is executable on your Linux server, the following command can then be used to execute Terraform.

```
source .aws/config
./make.sh terraform plan
./make.sh terraform apply
```

The provisioning will take a while but the command execution should show the progress.

### Running Terraform Commands ###
To run Terraform commands, you must first change directory to the terraform directory:

cd terraform
Then, you can run the following commands:

* terraform init: Initializes the Terraform working directory.
* terraform destroy: Destroys the Terraform-provisioned infrastructure.
To run the following commands, you must change directory back to the root directory of the repository:

* cd ..
Then, you can run the following commands:

* ./make.sh terraform plan: Generates a plan of the Terraform configuration.
* ./make.sh terraform apply: Applies the Terraform configuration.

### Setup Bastion ###
Once the terraform execution completes, you should now be able to SSH to the bastion using the SSH private key. The bastion pubic IP address can now be found in the AWS console.

Once you have logged in to the bastion, follow the steps below to install Ansible.

```
sudo apt install python3-pip
pip3 install boto3
pip3 install ansible
```


### Executing Ansible ###
You can either copy this cloned git files to the bastion server, or git clone it from the repository again. If you choose to do the latter then you will need to create .aws/config file again on the bastion server.

Ansible has been configured to automatically determine the servers to deploy the cluster from EC2 tags. Tags were created during the Terraform step. The ansible assumes all servers with the tag defined in `ansible/inventory/axonops/aws_ec2.yml` file.

The configurations for Cassandra are defined in `ansible/group_vars/tag_ClusterName_axonops/*.yml`
tag_ClusterName_axonops must match the key and value of the tag for the cluster.


Follow the steps below to execute Ansible to deploy a Cassandra cluster

1. Make sure passwordless SSH to target Cassandra servers are setup from the bastion
2. Check the user has passwordless sudo on the target servers
3. execute Ansible using the following set of commands:
```
source .aws/config
cd ansible
bash apache-cassandra-axonops.sh
```



### Starting Cassandra ###
Use the following command to start the cluster.
```
source .aws/config
cd ansible
bash start-cassandra.sh
```
