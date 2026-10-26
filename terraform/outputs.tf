output "cluster_name" {
  value = module.eks.cluster_name
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "sonarqube_url" {
  value = "http://${aws_instance.jenkins.public_ip}:9000"
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/jenkins_key ubuntu@${aws_instance.jenkins.public_ip}"
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}
