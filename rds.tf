resource "aws_db_subnet_group" "mysql_subnet" {
    name = "rds-subnet"
    description = "RDS subnet group"

    subnet_ids = [
        "${aws_subnet.cj_private_subnet1.id}",
        "${aws_subnet.cj_private_subnet2.id}"
    ]
}

resource "aws_db_instance" "cj_db" {
    allocated_storage = 5
    engine = "mysql"
    engine_version = "5.7.22"
    instance_class = "db.t2.micro"
    username = "admin"
    password = "admin1q2w3e"
    skip_final_snapshot = true

    db_subnet_group_name = "${aws_db_subnet_group.mysql_subnet.id}"
    vpc_security_group_ids = [
        "${aws_security_group.cj_rds_security.id}"
    ]
}
