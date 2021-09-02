terraform {
  backend "gcs" {
    bucket  = "rj-tf-state-backend"
    prefix  = "three-tier/state"
  }
}