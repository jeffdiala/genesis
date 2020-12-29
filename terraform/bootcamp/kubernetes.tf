resource "google_container_cluster" "gcp_kubernetes" {
  name               = var.cluster_name
  location           = "us-central1-a"
  initial_node_count = var.cluster_count

  node_locations = [
    "us-central1-b",
    "us-central1-c",
  ]

  master_auth {
    username = var.linux_admin_username
    password = var.linux_admin_password
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    tags = ["dev", "work"]
  }
}


resource "google_sql_database" "database" {
  name     = var.sql_name
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_database_instance" "instance" {
  name   = "k8s-dashdb-instance"
  region = "us-central1"

  settings {
    tier = "db-f1-micro"
  }
}