resource "aws_iam_role" "fargate_iam_role" {
  name               = "${var.name}-fargate-task-execution-role"
  assume_role_policy = "${data.aws_iam_policy_document.fargate_iam_policy_document.json}"
}

data "aws_iam_policy_document" "fargate_iam_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "fargate_iam_role_policy_attachment" {
  role       = "${aws_iam_role.fargate_iam_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "template_file" "fargate" {
  template = "${file("${path.module}/templates/fargate.tpl")}"

  vars {
    NAME       = "${var.name}"
    AWS_REGION = "${var.aws_region}"
    ENV        = "${var.env}"
  }
}
