resource "aws_vpc" "cj" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"

    tags {
        Name = "CJ VPC"
    }
}

data "aws_availability_zones" "available" {}

resource "aws_default_route_table" "cj" {
    default_route_table_id = "${aws_vpc.cj.default_route_table_id}"

    tags {
        Name = "default"
    }
}

resource "aws_subnet" "cj_public_subnet1" {
  vpc_id = "${aws_vpc.cj.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    Name = "cj public-az-1"
  }
}

resource "aws_subnet" "cj_public_subnet2" {
  vpc_id = "${aws_vpc.cj.id}"
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags = {
    Name = "cj public-az-2"
  }
}

resource "aws_subnet" "cj_private_subnet1" {
  vpc_id = "${aws_vpc.cj.id}"
  cidr_block = "10.0.11.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    Name = "cj private-az-1"
  }
}

resource "aws_subnet" "cj_private_subnet2" {
  vpc_id = "${aws_vpc.cj.id}"
  cidr_block = "10.0.12.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags = {
    Name = "cj private-az-2"
  }
}

resource "aws_internet_gateway" "cj_igw" {
    vpc_id = "${aws_vpc.cj.id}"

    tags = {
        Name = "cj internet-gateway"
    }
}
    
resource "aws_route" "cj_internet_access" {
  route_table_id = "${aws_vpc.cj.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.cj_igw.id}"
}    

resource "aws_eip" "cj_nat_eip" {
    vpc = true
    depends_on = ["aws_internet_gateway.cj_igw"]
}

resource "aws_nat_gateway" "cj_nat"{
    allocation_id = "${aws_eip.cj_nat_eip.id}"
    #subnet_id = "${aws_subnet.cj_public_subnet1.id}"
    subnet_id = "${aws_subnet.cj_private_subnet1.id}"
    depends_on = ["aws_internet_gateway.cj_igw"]
}


resource "aws_route_table" "cj_private_route_table" {
    vpc_id = "${aws_vpc.cj.id}"

    tags {
        Name = "cj private route table"
    }
}

resource "aws_route" "private_route" {
    route_table_id = "${aws_route_table.cj_private_route_table.id}"
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.cj_nat.id}"
}

resource "aws_route_table_association" "cj_public_subnet1_association" {
  subnet_id = "${aws_subnet.cj_public_subnet1.id}"
  route_table_id = "${aws_vpc.cj.main_route_table_id}"
}

resource "aws_route_table_association" "cj_public_subnet2_association" {
  subnet_id = "${aws_subnet.cj_public_subnet2.id}"
  route_table_id = "${aws_vpc.cj.main_route_table_id}"
}

resource "aws_route_table_association" "cj_private_subnet1_association" {
  subnet_id = "${aws_subnet.cj_private_subnet1.id}"
  route_table_id = "${aws_route_table.cj_private_route_table.id}"
}

resource "aws_route_table_association" "cj_private_subnet2_association" {
  subnet_id = "${aws_subnet.cj_private_subnet2.id}"
  route_table_id = "${aws_route_table.cj_private_route_table.id}"
}

resource "aws_default_security_group" "cj_default" {
  vpc_id = "${aws_vpc.cj.id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "default"
  }
}

resource "aws_security_group" "cj_security" {
  name = "cj_security"
  description = "Security group"
  vpc_id = "${aws_vpc.cj.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "cj security group"
  }
}

resource "aws_security_group" "cj_rds_security" {
  name = "cj_rds_security"
  description = "RDS Security group"
  vpc_id = "${aws_vpc.cj.id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.0.11.0/24"]
  }

  egress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "cj RDS security group"
  }
}

resource "aws_security_group" "cj_alb_security" {
  name = "cj_alb_security"
  description = "Security group"
  vpc_id = "${aws_vpc.cj.id}"

 # ingress {
 #   from_port = 22
 #   to_port = 22
 #   protocol = "tcp"
 #   cidr_blocks = ["0.0.0.0/0"]
 # }

 # ingress {
 #   from_port = 80
 #   to_port = 80
 #   protocol = "tcp"
 #   cidr_blocks = ["0.0.0.0/0"]
 # }

 # egress {
 #   from_port = 0
 #   to_port = 0
 #   protocol = "-1"
 #   cidr_blocks = ["0.0.0.0/0"]
 # }

  tags {
    Name = "cj ALB security group"
  }
}
