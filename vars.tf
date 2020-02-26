variable "stack_name" {
  default = "tf-dome9-stack"
}

variable "aws_account_id" {
  default = "xxxxxxxxxxxx"
}

variable "aws_access_key" {
  default = "XXXXXXXXXXXXXXXXXXXX"
}

variable "aws_secret_key" {
  default = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

# found that dome9 is generating a different "key" and both are necessary.
# this was a change to original template - that just used external_id

variable "d9_external_id" {
  default = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

variable "external_id" {
  default = "xxxxxxxxxxxxxxxxxxxxxxxx"
}

#Dome9 Secret

variable "secret" {
  default = "xxxxxxxxxxxxxxxxxxxxxxxx"
}

