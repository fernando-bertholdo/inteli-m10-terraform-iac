# Provisiona via IaC o papel do runner self-hosted do pipeline PX4 SITL do
# módulo (espelha a VM srv-simulador usada no repo de referência
# josercf/inteli-px4-cicd-demo — branch feat/pr8-terraform-runner). A
# decisão por runner self-hosted está
# documentada nos ADRs 001/006 daquele repo: GitHub-hosted cancelava o job
# de simulação; self-hosted + cache local da imagem SITL resolveu.

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

# Security Group: acesso SSH para administração do runner
# (espelha o acesso "ssh azureuser@srv-simulador" do walkthrough da aula 08)
resource "aws_security_group" "runner_ssh" {
  name        = "px4-runner-ssh"
  description = "SSH para administracao do runner self-hosted PX4"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # demo academica; em producao, restringir ao IP do time
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "px4-runner-ssh"
    Project = "inteli-m10"
  }
}

# EC2 do runner: user_data instala Docker + Compose no primeiro boot —
# pré-requisito do job mission-test (docker compose up ... --exit-code-from tester)
resource "aws_instance" "px4_runner" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro" # Free Tier 2025 (t2.micro nao mais elegivel); em uso real, instancia maior p/ SITL
  vpc_security_group_ids = [aws_security_group.runner_ssh.id]

  user_data = <<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y docker.io docker-compose-v2
    systemctl enable --now docker
    usermod -aG docker ubuntu
    # Próximo passo (fora do escopo desta demo): registrar o runner no GitHub
    # Actions com ./config.sh --labels px4-sitl e rodar ./run.sh como serviço.
    echo "runner bootstrap ok" > /var/log/runner-bootstrap.log
  EOF

  tags = {
    Name    = "px4-sitl-runner"
    Project = "inteli-m10"
    Role    = "ci-self-hosted-runner"
  }
}
