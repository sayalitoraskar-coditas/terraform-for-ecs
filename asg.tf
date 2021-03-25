resource "aws_iam_role" "ecs-instance-role" {
  name = "ecs-instance-role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = aws_iam_role.ecs-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_service_role" {
  name = "ecs_service_role-demo"
  role = aws_iam_role.ecs-instance-role.name
}

resource "aws_launch_configuration" "asg_config" {
  name                = var.aws_launch_configuration
  image_id            = var.image_id
  instance_type       = var.instance_type
  key_name            = aws_key_pair.ecs_keypair.id
  user_data           = "${data.template_file.init.rendered}"
  iam_instance_profile = aws_iam_instance_profile.ecs_service_role.name

  security_groups = ["${aws_security_group.secgroup-for-ecs.id}"]
  associate_public_ip_address = "true"
}

data "template_file" "init" {
  template = "${file("script.sh")}"
  vars = {
    name = "${var.cluster_name}"
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "asg-for-cluster-demo"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  launch_configuration      = aws_launch_configuration.asg_config.name
  vpc_zone_identifier       = ["${aws_subnet.sub-1.id}"]
  target_group_arns         = [aws_lb_target_group.tg.arn]
}

resource "aws_lb" "lb" {
  name               = "lb-for-cluster-demo"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.secgroup-for-ecs.id}"]
  subnets            = ["${aws_subnet.sub-1.id}","${aws_subnet.sub-2.id}","${aws_subnet.sub-3.id}"]
}

resource "aws_lb_target_group" "tg" {
  name               = "targer-group-for-lb"
  port               = 80
  protocol           = "HTTP"
  target_type        = "instance"
  vpc_id             = aws_vpc.private-net-for-ecs.id

  health_check {
    protocol = "HTTP"
    path = "/"
  }
}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

output "lb-dns" {
  value = aws_lb.lb.dns_name
}