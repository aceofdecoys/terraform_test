resource "aws_alb" "cj_alb" {
    name    = "cj-alb-test"
    internal = false
    security_groups = ["${aws_security_group.cj_alb_security.id}"]

    subnets =[ "${aws_subnet.cj_public_subnet1.id}", "${aws_subnet.cj_public_subnet2.id}"]

    tags {
        Name = "ALB TEST"
    }

    lifecycle { 
        create_before_destroy = true 
    }
}


resource "aws_alb_target_group" "cj_alb_target" {
    name     = "cj-alb-target-group"
    port     = 80
    protocol = "HTTP"
    vpc_id   = "${aws_vpc.cj.id}"

    health_check {
        interval            = 15
        path                = "/ping"
        healthy_threshold   = 3
        unhealthy_threshold = 3
    }

    tags { Name = "Frontend Target GRP" }
}


resource "aws_alb_target_group_attachment" "cj_alb_target_group_attach" {
    target_group_arn = "${aws_alb_target_group.cj_alb_target.arn}"
    target_id        = "${element(aws_instance.cj_instance.*.id, count.index)}"
    port             = 8080
}

resource "aws_alb_listener" "http" {
    load_balancer_arn = "${aws_alb.cj_alb.arn}"
    port                = "80"
    protocol            = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.cj_alb_target.arn}"
        type            = "forward"
    }
}

