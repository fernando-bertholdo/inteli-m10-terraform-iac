# Tutorial oficial HashiCorp "Get Started - AWS" (aws-build/aws-create)
# Região ajustada para us-east-1 (AWS Academy Learner Lab)

provider "aws" {
  region = "us-east-1"
}

# Data source: busca dinamicamente a AMI Ubuntu 24.04 mais recente da Canonical,
# evitando hardcode de ID que envelhece e muda por região.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami = data.aws_ami.ubuntu.id
  # O tutorial usa t2.micro; o novo Free Tier da AWS (contas criadas em 2025)
  # só permite t3.micro/t4g.micro. t3.micro é o equivalente x86_64 atual e
  # roda a mesma AMI Ubuntu AMD64. Ver seção "Adaptações" no README.
  instance_type = "t3.micro"

  tags = {
    Name = "learn-terraform"
  }
}
