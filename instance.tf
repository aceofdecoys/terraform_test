resource "aws_key_pair" "cj_test" {
    key_name = "cj_test"
    public_key = "${file("~/.ssh/cj_test.pub")}"
}


variable "aws_zone" {
    default = [
        "ap-northeast-2a",
        "ap-northeast-2c"
    ]
}


resource "aws_instance" "cj_instance" {

    connection {
        user = "ec2-user"
        type = "ssh"
        private_key = "${file("~/.ssh/cj_test")}"
        timeout = "2m"
        agent = false
    }

    ami = "ami-095ca789e0549777d" #LINUX 2 AMI
    instance_type = "t2.micro"
    count = 2
    key_name = "${aws_key_pair.cj_test.key_name}"

    vpc_security_group_ids = [
        "${aws_default_security_group.cj_default.id}",
        "${aws_security_group.cj_security.id}"
    ]

    subnet_id = "${aws_subnet.cj_public_subnet1.id}"

    associate_public_ip_address = true

    provisioner "file" {
       source = "config/proxy"
       destination = "/home/ec2-user/proxy" 

        connection {
            user = "ec2-user"
            type = "ssh"
            private_key = "${file("~/.ssh/cj_test")}"
            timeout = "2m"
            agent = false
        }
    }

    provisioner "remote-exec" {
        inline = [
        "sudo amazon-linux-extras install -y nginx1.12",
        "sudo mkdir /etc/nginx/sites-available",
        "sudo mkdir /etc/nginx/sites-enabled",
        "sudo mv /home/ec2-user/proxy /etc/nginx/sites-available/proxy",
        "sudo ln -s /etc/nginx/sites-available/proxy /etc/nginx/sites-enabled/proxy",
        "sudo service nginx start",
        ]
    } 


   tags {
       Name = "EC2 Server ${count.index}"
   }
}

resource "aws_eip" "cj_eip" {
    vpc = true
    instance = "${element(aws_instance.cj_instance.*.id, count.index)}"
    depends_on = ["aws_internet_gateway.cj_igw"]
}

resource "aws_instance" "cj_instance_private" {

    connection {
        user = "ec2-user"
        type = "ssh"
        private_key = "${file("~/.ssh/cj_test")}"
        timeout = "2m"
        agent = false
    }

    ami = "ami-095ca789e0549777d" #LINUX 2 AMI
    instance_type = "t2.micro"
    count = 2
    key_name = "${aws_key_pair.cj_test.key_name}"

    vpc_security_group_ids = [
        "${aws_default_security_group.cj_default.id}",
        "${aws_security_group.cj_security.id}"
    ]

    subnet_id = "${aws_subnet.cj_private_subnet1.id}"

    associate_public_ip_address = true

   tags {
       Name = "EC2 Private Server ${count.index}"
   }
}
