resource "aws_vpc" "dmz" {
    cidr_block = "10.1.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags {
        Name = "DMZ"
    }
}

resource "aws_subnet" "dmz_public_2a"
{
    vpc_id = "${aws_vpc.dmz.id}"
    cidr_block = "10.1.1.0/24"
    availability_zone = "ap-northeast-2a"

    tags {
        Name = "DMZ public 2A"
    }
}

resource "aws_default_route_table" "dmz_main" {
    default_route_table_id = "${aws_vpc.dmz.default_route_table_id}"

    tags {
        Name = "DMZ ROUTE TABLE"
    }
}

resource "aws_subnet" "dmz_public_2c"
{
    vpc_id = "${aws_vpc.dmz.id}"
    cidr_block = "10.1.2.0/24"
    availability_zone = "ap-northeast-2c"

    tags {
        Name = "DMZ public 2C"
    }
}

################
resource "aws_route_table_association" "dmz_public_2a" {
    subnet_id = "${aws_subnet.dmz_public_2a.id}"
    route_table_id = "${aws_vpc.dmz.default_route_table_id}"
}

resource "aws_route_table_association" "dmz_public_2c" {
    subnet_id = "${aws_subnet.dmz_public_2c.id}"
    route_table_id = "${aws_vpc.dmz.default_route_table_id}"
}



resource "aws_internet_gateway" "dmz" {
    vpc_id = "${aws_vpc.dmz.id}"

    tags {
        Name = "DMZ INTERNET GATEWAY"
    }
}

resource "aws_route" "dmz_public" {
    route_table_id = "${aws_vpc.dmz.default_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.dmz.id}"
}
