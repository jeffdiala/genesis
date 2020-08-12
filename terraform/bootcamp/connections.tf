// Configure the Google Cloud provider
provider "google" {
  credentials = file("./secrets/account.json")
  project     = var.gcp_project_name
  region      = var.gcp_project_region
}
