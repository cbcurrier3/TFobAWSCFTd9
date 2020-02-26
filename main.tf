provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region     = "us-east-2"
}

provider "dome9" {
  dome9_access_id     = var.d9_external_id
  dome9_secret_key    = var.secret
}

data "aws_ami" "amazon-linux-2" {
    most_recent = true
    owners = ["591542846629"] # AWS

 filter {
    name   = "name"
    values = ["*amazon-ecs-optimized"]
 }

 filter {
    name   = "virtualization-type"
    values = ["hvm"]
 }  
}

locals {
  module_path = replace(path.module, "\\", "/")
}

resource "aws_cloudformation_stack" "tf-dome9-stack" {

    name = "tf-dome9-stack"
    capabilities = ["CAPABILITY_IAM"]
    parameters = {
        AmiName = data.aws_ami.amazon-linux-2.id
        SubnetAZa = "us-east-2a"
        SubnetAZb = "us-east-2b"
        SubnetAZc = "us-east-2c"
 }

  template_body = file("D9-Template-Feb2019.json")

}

#Create the role and setup the trust policy
resource "aws_iam_role" "dome9" {
  name               = "Dome9-Connect"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::634729597623:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${var.external_id}"
        }
      }
    }
  ]
}
EOF
}

#Create the readonly policy
resource "aws_iam_policy" "readonly-policy" {
    name        = "Dome9-readonly-policy"
    description = ""
    policy      = file("readonly-policy.json")
}

#Create the write policy
resource "aws_iam_policy" "write-policy" {
    name        = "Dome9-write-policy"
    description = ""
    policy      = file("write-policy.json")
}

#Attach 4 policies to the cross-account role
resource "aws_iam_policy_attachment" "attach-d9-read-policy" {
    name       = "Attach-readonly"
    roles      = [aws_iam_role.dome9.name]
    policy_arn = aws_iam_policy.readonly-policy.arn
}

resource "aws_iam_policy_attachment" "attach-d9-write-policy" {
    name       = "Attach-write"
    roles      = [aws_iam_role.dome9.name]
    policy_arn = aws_iam_policy.write-policy.arn
}

resource "aws_iam_role_policy_attachment" "attach-security-audit" {
    role       = aws_iam_role.dome9.name
    policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "attach-inspector-readonly" {
    role       = aws_iam_role.dome9.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonInspectorReadOnlyAccess"
}

resource "dome9_cloudaccount_aws" "d9aws" {
  name                   = var.stack_name

  credentials  {
    arn    = aws_iam_role.dome9.arn
    secret = var.external_id
    type   = "RoleBased"
  }

 net_sec {
    regions {
      new_group_behavior = "FullManage"
      region             = "us_east_1"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "us_west_1"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "eu_west_1"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "ap_southeast_1"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "ap_northeast_1"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "us_west_2"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "sa_east_1"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "ap_southeast_2"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "eu_central_1"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "ap_northeast_2"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "ap_south_1"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "us_east_2"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "ca_central_1"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "eu_west_2"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "eu_west_3"
    }
    regions {
      new_group_behavior = "FullManage"
      region             = "eu_north_1"
    }
  }
}

#Output the role ARN
output "Role_ARN" {
  value = aws_iam_role.dome9.arn
}
