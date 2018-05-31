resource "google_container_cluster" "dev" {
  name               = "dev"
  region             = "us-west1"
  initial_node_count = 1
  min_master_version = "1.10.2-gke.3"

  //node_pool = "${google_container_node_pool.dev.name}"

  master_authorized_networks_config {
    cidr_blocks = {
      cidr_block   = "${var.home_network}"
      display_name = "home_network"
    }
  }
  master_auth = {
    password = ""
    username = ""
  }
  maintenance_policy {
    daily_maintenance_window {
      start_time = "11:00"
    }
  }
  remove_default_node_pool = true
  monitoring_service       = "none"
  logging_service          = "none"
  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }

    http_load_balancing {
      disabled = false
    }

    kubernetes_dashboard {
      disabled = false
    }

    network_policy_config {
      disabled = false
    }
  }
}

resource "google_container_node_pool" "dev" {
  name       = "dev"
  region     = "us-west1"
  cluster    = "${google_container_cluster.dev.name}"
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "n1-standard-1"

    preemptible = true

    disk_size_gb = 20

    labels = {
      name  = "nodes-dev"
      owner = "Joe-Stevens"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
