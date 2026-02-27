# SECURITY GROUP
resource "aws_security_group" "react_sg" {
  name        = var.sg_name
  description = "Allow HTTP, HTTPS, SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_name
  }
}

resource "aws_launch_template" "blue_lt" {
  name_prefix   = "react-blue-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.react_sg.id]
   iam_instance_profile {
  name = aws_iam_instance_profile.ec2_profile.name
  }
  metadata_options {
  http_tokens   = "optional"    # allows IMDSv1
  http_endpoint = "enabled"
}
user_data = base64encode(<<-EOF
#!/bin/bash

sleep 40

apt update -y
apt install -y git ansible python3-pip

pip3 install boto3 botocore
ansible-galaxy collection install community.aws

cd /home/ubuntu

git clone ${var.ansible_repo} app
cd app

git checkout ${var.blue_version}

ansible-playbook -i localhost, -c local playbook.yml -e "target_group_arn=${var.blue_target_group_arn}"

EOF
)
tag_specifications {
  resource_type = "instance"

  tags = {
    Environment = "blue"
  }
}

}

resource "aws_launch_template" "green_lt" {
  name_prefix   = "react-green-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.react_sg.id]
   iam_instance_profile {
  name = aws_iam_instance_profile.ec2_profile.name
    } 
    metadata_options {
  http_tokens   = "optional"    # allows IMDSv1
  http_endpoint = "enabled"
}
user_data = base64encode(<<-EOF
#!/bin/bash

sleep 40

apt update -y
apt install -y git ansible python3-pip

pip3 install boto3 botocore
ansible-galaxy collection install community.aws

cd /home/ubuntu
git clone ${var.ansible_repo} app
cd app

git checkout ${var.green_version}

ansible-playbook -i localhost, -c local playbook.yml -e "target_group_arn=${var.green_target_group_arn}"
  

EOF
)

tag_specifications {
  resource_type = "instance"

  tags = {
    Environment = "green"
  }
}
}


resource "aws_autoscaling_group" "blue_asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.public_subnets

  launch_template {
    id      = aws_launch_template.blue_lt.id
    version = "$Latest"
  }


  tag {
    key                 = "Name"
    value               = "react-blue-asg"
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_group" "green_asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.public_subnets

  launch_template {
    id      = aws_launch_template.green_lt.id
    version = "$Latest"
  }


  tag {
    key                 = "Name"
    value               = "react-green-asg"
    propagate_at_launch = true
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-ansible-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "elb_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ansible-profile"
  role = aws_iam_role.ec2_role.name
}
