# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "terraform-eks"
  type    = string
}
