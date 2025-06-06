#### variables ######

variable "ami_id" {
  description = "ID de la AMI"
  default     = "ami-084568db4383264d4"
}

variable "instance_type" {
  description = "Tipo de instancia"
  default     = "t3.micro"
}

variable "server_name" {
  description = "Nombre de la instancia"
  default     = "webserver"
}

variable "environment" {
  description = "Ambiente en el que está deplegado (Prod - PreProd - Dev)"
  default     = "Dev"
}

provider "aws" {
  region = "us-east-1"
}

# Importar la llave existente como data source
data "aws_key_pair" "existing_key" {
  key_name           = "andresc-bextsa" # Reemplaza con tu nombre real
  include_public_key = true
}

resource "aws_instance" "nginx-server" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  key_name          = data.aws_key_pair.existing_key.key_name
  availability_zone = "us-east-1a"
  user_data         = <<-EOF
                    #!/bin/bash
                    sleep 15
                    sudo apt-get update -y
                    sudo apt install nginx -y
                    sudo systemctl enable nginx
                    sudo systemctl start nginx
                    EOF

  tags = {
    Name        = var.server_name # ¡Este es el nombre que aparecerá en la consola AWS!
    Environment = var.environment
    Owner       = "andresc" # Tags adicionales (opcionales)
    Project     = "Terraform-AWS"
  }

}

output "public_ip" {
  description = "IP pública de la instancia"
  value       = aws_instance.nginx-server.public_ip
}

output "public_dns" {
  description = "DNS público de la instancia"
  value       = aws_instance.nginx-server.public_dns
}

output "availability_zone" {
  description = "DNS público de la instancia"
  value       = aws_instance.nginx-server.availability_zone
}
