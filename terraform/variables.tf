variable "region" {
  default = "ap-south-1"
}

variable "project" {
  default = "react-cicd"
}

variable "k8s_version" {
  default = "1.37"
}

variable "my_ip" {
  description = "Your public IP, for SSH and SonarQube access"
}
