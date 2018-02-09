resource "aws_ecs_cluster" "fargate_ecs_cluster" {
  name = "${var.name}-fargate"
}

resource "aws_cloudwatch_log_group" "fargate_log_group" {
  name = "${var.name}-fargate"
}

resource "aws_ecs_task_definition" "fargate_task_definition" {
  family                   = "fargate"
  container_definitions    = "${data.template_file.fargate.rendered}"
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = "${aws_iam_role.fargate_iam_role.arn}"
}

resource "aws_ecs_service" "fargate_ecs_service" {
  name            = "${var.name}-fargate"
  cluster         = "${aws_ecs_cluster.fargate_ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.fargate_task_definition.arn}"
  desired_count   = 2
  iam_role        = "${aws_iam_role.fargate_iam_role.arn}"
  launch_type     = "FARGATE"

  load_balancer = {
    target_group_arn = "${aws_alb_target_group.fargate_target_group.arn}"
    container_name   = "blog"
    container_port   = 80
  }

  launch_type = "FARGATE"

  depends_on = ["aws_alb_listener.fargate_alb_listener"]
}
