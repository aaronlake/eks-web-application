data "aws_region" "current" {}

resource "kubernetes_namespace" "demo_app" {
  metadata {
    name = "demo-app"
  }
}

resource "kubernetes_secret" "connection_string" {
  metadata {
    name      = "connection-string"
    namespace = kubernetes_namespace.demo_app.metadata[0].name
    labels = {
      "sensitive" = "true"
      "app"       = "demo-app"
    }
  }

  data = {
    connection_string = "mongodb://admin:${random_pet.mongodb_password.id}@${aws_instance.mongodb.private_ip}:27017/?authSource=admin"
  }
}

resource "aws_ecr_repository" "demo_app" {
  name = "demo-app"
}

locals {
  all_files       = fileset("${path.module}/app/", "**/*")
  file_hashes     = [for f in local.all_files : filesha256("${path.module}/app/${f}")]
  aggregated_hash = sha256(join("", local.file_hashes))
}

resource "null_resource" "demo_app" {
  triggers = {
    always_run = local.aggregated_hash
  }

  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.demo_app.repository_url}"
  }

  provisioner "local-exec" {
    command = "docker buildx build --platform linux/amd64, -t ${aws_ecr_repository.demo_app.repository_url}:latest ${path.module}/app"
  }

  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.demo_app.repository_url}:latest"
  }

  depends_on = [aws_ecr_repository.demo_app]
}

resource "kubernetes_service_account" "demo_app_sa" {
  metadata {
    name      = "demo-app-sa"
    namespace = kubernetes_namespace.demo_app.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "demo_app_cluster_admin" {
  metadata {
    name = "demo-app-cluster-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.demo_app_sa.metadata[0].name
    namespace = kubernetes_service_account.demo_app_sa.metadata[0].namespace
  }
}

resource "kubernetes_deployment" "demo_app" {
  metadata {
    name      = "demo-app"
    namespace = kubernetes_namespace.demo_app.metadata[0].name
    labels = {
      "app" = "demo-app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        "app" = "demo-app"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "demo-app"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.demo_app_sa.metadata[0].name

        container {
          image = "${aws_ecr_repository.demo_app.repository_url}:latest"
          name  = "demo-app"

          env {
            name  = "CONNECTION_STRING"
            value = kubernetes_secret.connection_string.data.connection_string
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "demo_app" {
  metadata {
    name      = "demo-app"
    namespace = kubernetes_namespace.demo_app.metadata[0].name
  }

  spec {
    selector = {
      "app" = "demo-app"
    }

    port {
      port        = 80
      target_port = 5000
    }

    type = "LoadBalancer"
  }
}
