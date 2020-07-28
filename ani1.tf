provider "aws" {
  region     = "ap-south-1"
  profile    = "tony"
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP SSH inbound traffic"
  vpc_id      = "vpc-d4ebf6bc"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "my_http"
  }
}

resource "aws_instance" "myweb" {
	ami		= "ami-005956c5f0f757d37"
	instance_type	="t2.micro"
	key_name          = "aniket1234"
  	security_groups   = [ "allow_http" ]

	 connection {
    	type        = "ssh"
    	user        = "ec2-user"
    	private_key = file("C:/Users/Anjali/Downloads/aniket1234.pem")
    	host        = "${aws_instance.myweb.public_ip}"
  	}
  
 	 provisioner "remote-exec" {
    	inline = [
      	"sudo yum install httpd  -y",
      	"sudo service httpd start",
      	"sudo service httpd enable"
    	]
 	 }

	tags = {
		Name = "Aniketos"
	}
}

output "o3" {
	value = aws_instance.myweb.public_ip
}

output "o4" {
	value = aws_instance.myweb.availability_zone
}


resource "aws_s3_bucket" "myuniquebucket1227" {
  bucket = "myuniquebucket1227" 
  acl    = "public-read"
  tags = {
    Name        = "uniquebucket1227" 
  }
  versioning {
	enabled =true
  }
}

resource "aws_s3_bucket_object" "s3object" {
  bucket = "${aws_s3_bucket.myuniquebucket1227.id}"
  key    = "1076883.jpg"
  source = "C:/Users/Anjali/Downloads/1076883.jpg"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "This is origin access identity"
}

resource "aws_cloudfront_distribution" "imagecf" {
    origin {
        domain_name = "myuniquebucket1227.s3.amazonaws.com"
        origin_id = "S3-myuniquebucket1227"


        s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
       
    enabled = true
      is_ipv6_enabled     = true

    default_cache_behavior {
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "S3-myuniquebucket1227"


        # Forward all query strings, cookies and headers
        forwarded_values {
            query_string = false
        
            cookies {
               forward = "none"
            }
        }
        viewer_protocol_policy = "allow-all"
        min_ttl = 0
        default_ttl = 10
        max_ttl = 30
    }
    # Restricts who is able to access this content
    restrictions {
        geo_restriction {
            # type of restriction, blacklist, whitelist or none
            restriction_type = "none"
        }
    }


    # SSL certificate for the service.
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}

resource “aws_efs_file_system” “efs_plus” {
depends_on = [aws_security_group.abhitf_sg, aws_instance.AbhiOs1]
creation_token = “efs”
tags = {
Name = “aniefs”
}
}
resource “aws_efs_mount_target” “mount_efs” {depends_on = [aws_efs_file_system.efs_plus]
file_system_id = aws_efs_file_system.efs_plus.id
subnet_id = aws_instance.Aniketos.subnet_id
security_groups=[aws_security_group.anitf_sg.id]
}
resource “null_resource” “cluster” {
depends_on = [
aws_efs_file_system.efs_plus,
]
connection {
type = “ssh”
user = “ec2-user”
private_key = file("C:/Users/Anjali/Downloads/aniket1234.pem")
host = aws_instance.Aniketos.public_ip
}
provisioner “remote-exec” {
inline = [“sudo echo ${aws_efs_file_system.efs_plus.dns_name}:/var/www/html efs defaults._netdev 0 0>>sudo /etc/fstab”,
“sudo mount ${aws_efs_file_system.efs_plus.dns_name}:/var/www/html/*”,
“sudo rm -rf /var/www/html/*”,
“sudo git clone https://github.com/aniketambasta/aws_task_2 /var/www/html “
   ]
  }
}
