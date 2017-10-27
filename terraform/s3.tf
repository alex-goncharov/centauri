data "aws_iam_policy_document" "ca" {
  statement {
    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::${data.aws_caller_identity.current_user.account_id}-tnt-digital.io.ca",
      "arn:aws:s3:::${data.aws_caller_identity.current_user.account_id}-tnt-digital.io.ca/*",
    ]

    principals = {
      type = "AWS"

      identifiers = [
        "${aws_iam_role.worker.arn}",
        "${aws_iam_role.master.arn}",
        "arn:aws:iam::156776894708:user/alex.goncharov",
      ]
    }
  }
}

resource "aws_s3_bucket" "ca" {
  bucket        = "${data.aws_caller_identity.current_user.account_id}-tnt-digital.io.ca"
  policy        = "${data.aws_iam_policy_document.ca.json}"
  force_destroy = true
}
