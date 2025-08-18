# main.tf
# --------------------------------------------------------------------------------------------------
# Data sources to find existing network components
# These data blocks find the VPC and public subnet by their IDs,
# making the configuration reusable across different environments.
data "aws_subnet" "public" {
  id = "subnet-061b9b92847668e62"
}

data "aws_vpc" "selected" {
  id = data.aws_subnet.public.vpc_id # Gets the VPC ID from the subnet.
}

# --------------------------------------------------------------------------------------------------
# Data source to find the latest Amazon Linux 2023 AMI
# This dynamic lookup ensures you always use the most recent image.
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# --------------------------------------------------------------------------------------------------
# Create a security group in the selected VPC
resource "aws_security_group" "allow_ssh" {
  name        = "wilson-tf-sg" # ⬅️ CHANGE TO YOUR SECURITY GROUP NAME
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.selected.id # Use the dynamically found VPC ID.
}

# --------------------------------------------------------------------------------------------------
# Add an ingress rule to the security group for SSH
resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_ssh.id
}

# --------------------------------------------------------------------------------------------------
## Create the EC2 instance
resource "aws_instance" "public" {
  count = 2 # ⬅️ This is the key change!

  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = "wilson_key" # ⬅️ CHANGE TO YOUR KEY PAIR NAME
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "${var.name}-ec2-${count.index}" # ⬅️ Use count.index to create unique names
  }
}
