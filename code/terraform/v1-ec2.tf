provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-053b0d53c279acc90"
    instance_type = "t2.micro"
    key_name = "demo"
	  vpc_security_group_ids = [aws_security_group.demo-sg.id]
    subnet_id = aws_subnet.demo-public-subnet-01.id 
    for_each = toset(["jenkins-master", "jenkins-slave", "ansible"])
    tags = {
      Name = "${each.key}"
    }
      
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  vpc_id = aws_vpc.demo-vpc.id
  ingress {
    description      = "SSH access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 ingress {
    description      = "Jenkins access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-sg"
  }
}

resource "aws_vpc" "demo-vpc" {
    cidr_block = "10.1.0.0/16"
    tags = {
        Name = "demovpc"
    }
}

resource "aws_subnet" "demo-public-subnet-01" {
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
        Name = "demo-public-subnet-01"
    }
}

resource "aws_internet_gateway" "demo-igw" {
    vpc_id = aws_vpc.demo-vpc.id
    tags = {
      Name = "demo-igw"
    }
  
}

resource "aws_route_table" "demo-rt" {
    vpc_id = aws_vpc.demo-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo-igw.id
    }
    tags = {
      Name = "demo-rt"  
    }
}

resource "aws_route_table_association" "demo-rta-public-subnet-1" {
    subnet_id = aws_subnet.demo-public-subnet-01.id
    route_table_id = aws_route_table.demo-rt.id
}