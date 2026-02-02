## Using Count

resource "aws_s3_bucket" "example" {
  count = var.env == dev ? 1 : 0  ## If env is dev, resources will be created with index example[0]
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


## Using for_each

resource "aws_s3_bucket" "example" {
  for_each = var.enable_resource_promotion ? true : {}
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

var enable_resource_promotion {
    type = bool
    description = Flag used to control resoures to promote into upstream env
    default = false ## change to true when promoting resources to prod
}