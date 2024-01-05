# Helios FHIR Server AWS Reference Architecture

## Introduction
This document provides recommended practices and a comprehensive setup instructions for a reference architecture for the Helios FHIR Server on AWS.

## Reference Architecture
This reference architecture consists of the following components:
- An Amazon Virtual Private Cloud (helios-vpc)
- Public and private subnets across two different availability zones for a total of 4 subnets.
- A bastion Linux instance used to provide secure access to Linux instances located in the private and public subnets of your virtual private cloud.  SSH to this instance to perform initial Cassandra cluster installation tasks, and occasional maintenance as required.
- A 5-node Cassandra Cluster with nodes spread across two availability zones.
- Helios FHIR Server installed in an Amazon EKS Cluster and configured for auto-scaling.
- IAM Roles and Policies
- Security Groups

![Helios FHIR Server AWS Reference Architecture](hfs-aws.png)

## Installation Prerequisites

- [Install Terraform](https://developer.hashicorp.com/terraform/install) on your local machine.
- Have an [AWS IAM User Account](https://aws.amazon.com/iam) and [create access keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey). In order to successfully provision this reference architecture the user must also be permitted to create the following AWS resources:
  - VPC - AmazonVPCFullAccess
  - EC2 - AmazonEC2FullAccess
  - IAM Role - IAMFullAccess
  - EKS - You will need to add a custom policy named EKS-Full-Access
    - `{
      "Version": "2012-10-17",
      "Statement": [
      {
      "Sid": "eksadministrator",
      "Effect": "Allow",
      "Action": "eks:*",
      "Resource": "*"
      }
      ]
      }`
  - Subnet
  - Route Table
  - Route Table Association
  - Security Group
  - Load Balancer (Application, Network, or Classic Load Balancer)
  - Launch Configuration
  - Auto Scaling Group
  - Target Group (if using Application or Network Load Balancer)
  - CloudWatch Alarm
  - IAM Instance Profile
  - IAM Role Policy
  - Route 53 (optional)


## Installation Overview
There are two high level steps in this automation:

1. Use Terraform to provision the resources in the `terraform` folder.
2. SSH to the Bastion Linux instance and run Ansible automation to provision Cassandra cluster on the Linux hosts provisioned in step 1.

## Installation Steps

### Preparation ###
1. Clone this repository.
2. At the root of this repository, manually create the following file.
```
./.aws/config
```
3. Add the following content to ./.aws/config
```
export AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY>
export AWS_DEFAULT_REGION=<AWS_DEFAULT_REGION>
export ANSIBLE_HOST_KEY_CHECKING=false
```
4. Run `source ./.aws/config`
5. Run `cd terraform`
6. Run `terraform init`

### Configure Terraform Variables ###

The `variables.tf` file contains several variables that you may want to modify such as specific AWS Regions, Zones and other settings.

Replace the local_ssh_pubkey default value to ~/.ssh/id_rsa.pub or ~/.ssh/id_ed25519.pub (default)

### Run Terraform Apply ###

Run `terraform apply`

The provisioning will take a while but the command execution should show the progress.

### SSH to the Bastion Linux Instance ###

The bastion public IP address can now be found in the AWS EC2 console named `Helios Bastion Server`.

From your local machine, connect to the instance:

`ssh ubuntu@[bastion ip address]`

Please NOTE:  It may take some time for the setup steps of the Bastion instance to complete.  The steps will be complete when the `/home/ubuntu/.ssh/id_ed25519` is available on the Bastion instance. 

### Clone this Repository (again) ###

From the Bastion Linux Instance, clone this repository.

`git clone https://github.com/HeliosSoftware/hfs-install.git`

Create the .aws directory 

`mkdir hfs-install/.aws`

### Copy your local .aws/config file to the Bastion Linux Instance ###

Logout of the bastion linux instance, or use a new local terminal, and execute this next command on your local machine from the `hfs-install/.aws` directory:

`cd ../.aws`

`scp config ubuntu@[bastion ip address]:~/hfs-install/.aws/config`

Connect again to the Bastion instance.

`ssh ubuntu@[bastion ip address]`

Verify that the .aws/config file is present and correct

`cat hfs-install/.aws/config`

### Execute Cassandra Ansible Setup Scripts fom the Bastion Linux Instance ###

`ssh ubuntu@[bastion ip address]`

```
cd hfs-install
source .aws/config
cd ansible
bash apache-cassandra-axonops.sh
```

### Manually Creating Key Pairs ###
You must manually create two key pairs in your AWS account named kubectl1-keypair and worker-keypair, both of type RSA. The declaration of these key pairs is in the worker.tf file.

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

The configurations for Cassandra are defined in `ansible/group_vars/tag_ClusterName_helios/*.yml`
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
