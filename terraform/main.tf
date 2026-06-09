data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft-server-sg"
  description = "Allow SSH and Minecraft traffic from trusted IP"

  ingress {
    description = "SSH for Ansible only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip_cidr]
  }

  ingress {
    description = "Minecraft Java Edition"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip_cidr]
  }

  egress {
    description = "Allow outbound internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "minecraft-server-sg"
  }
}

resource "aws_instance" "minecraft" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]

  tags = {
    Name = "automated-minecraft-server"
  }
}
