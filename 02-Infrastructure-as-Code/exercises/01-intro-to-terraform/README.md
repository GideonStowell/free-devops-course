# Intro to Terraform
1. To follow along, you must [Install the terraform CLI](https://developer.hashicorp.com/terraform/downloads) and create an AWS account and programmatic credentials (AWS Acess Key and Secret Key). Store the credentials in `~/.aws/credentials` like so:
```
[terraform]
aws_access_key_id=<access_key_here>
aws_secret_access_key=<secret_key_here>
```

2. You can see that I have terraform installed with this cli command `terraform -version`
```
user@computer →  terraform -version
Terraform v1.5.4
on linux_amd64
```

3. Now looking at this code, I first set up the providers. The providers are the libraries specific to the cloud service Terraform is going to use; in this case AWS. 
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
  profile = "terraform"
}
```
4. Next create an aws ec2 instance block and can specify the operating system using a data block lookup, a name and instance type. Also, add an AWS security group and rules that will allow traffic to reach the webserver.
```
data "aws_ami" "webserver_os" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.webserver_os.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.firewall.id]
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = "ExampleWebServers"
  }
}

resource "aws_security_group" "firewall" {
  name = "webserver-security-group"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
5. First run `terraform init` to download the required providers. Then run `terraform plan` to create a plan for my infrastructure. This allows the change to validate the resources are correct before creating the infrastructure. The `terraform plan` output looks like this (some lines ommitted for brevity):
```
user@computer →  terraform plan
data.aws_ami.webserver_os: Reading...
data.aws_ami.webserver_os: Read complete after 0s [id=ami-016d1b215ea28dcee]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.webserver will be created
  + resource "aws_instance" "webserver" {
      + ami                                  = "ami-016d1b215ea28dcee"
      ...
      + instance_type                        = "t2.micro"
      + tags                                 = {
          + "Name" = "ExampleWebServers"
        }
      + tags_all                             = {
          + "Name" = "ExampleWebServers"
        }
      ...
    }

  # aws_security_group.firewall will be created
  + resource "aws_security_group" "firewall" {
      ...
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 8080
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 8080
            },
        ]
      + name                   = "webserver-security-group"
      ...
    }

Plan: 2 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
6. Once the plan is validated manually, run `terraform apply` and the plan will be regenerated. Type "yes" to confim you want the plan created and it will begin to create the resources and provide a periodic update of which resources are being created or finished.
```
Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_security_group.firewall: Creating...
aws_security_group.firewall: Creation complete after 2s [id=sg-01513ea63bbd57389]
aws_instance.webserver: Creating...
aws_instance.webserver: Still creating... [10s elapsed]
aws_instance.webserver: Still creating... [20s elapsed]
aws_instance.webserver: Creation complete after 23s [id=i-0794aed958f55309b]
```

7. Now modify the EC2 instance. Add some more storage to it by changing the `root_block_device.volume_size` parameter. Then rerun `terraform plan` and see if the desired changes will take effect. And then rerun `terraform apply`.
```
user@computer→  terraform plan
data.aws_ami.webserver_os: Reading...
aws_security_group.firewall: Refreshing state... [id=sg-09a878c7e7f97a59e]
data.aws_ami.webserver_os: Read complete after 1s [id=ami-016d1b215ea28dcee]
aws_instance.webserver: Refreshing state... [id=i-0d4f7ccc897683be6]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.webserver will be updated in-place
  ~ resource "aws_instance" "webserver" {
        id                                   = "i-0d4f7ccc897683be6"
        tags                                 = {
            "Name" = "ExampleWebServers"
        }
        # (32 unchanged attributes hidden)

      ~ root_block_device {
            tags                  = {}
          ~ volume_size           = 8 -> 10
            # (7 unchanged attributes hidden)
        }

        # (7 unchanged blocks hidden)
    }
```

8. Now to cleanup! Run `terraform destory` and see the report of resources that will be removed. Type "yes" to confirm removing these resources and they will be automatically cleaned up:
```
user@computer →  terraform destroy 
data.aws_ami.webserver_os: Reading...
aws_security_group.firewall: Refreshing state... [id=sg-09a878c7e7f97a59e]
data.aws_ami.webserver_os: Read complete after 0s [id=ami-016d1b215ea28dcee]
aws_instance.webserver: Refreshing state... [id=i-0d4f7ccc897683be6]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.webserver will be destroyed
  - resource "aws_instance" "webserver" {
      - ami = "ami-016d1b215ea28dcee" -> null
      ...

      - root_block_device {
          - volume_size = 10 -> null
        }
    }

  # aws_security_group.firewall will be destroyed
  - resource "aws_security_group" "firewall" {
      - description            = "Managed by Terraform" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 8080
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 8080
            },
        ] -> null
    }

Plan: 0 to add, 0 to change, 2 to destroy.
```

9. Well done! You've just completed your first Terraform exercise! 🙌️