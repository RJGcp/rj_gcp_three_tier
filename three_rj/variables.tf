variable "project_id" {
  type        = string
  description = "The project to run tests against"
  default = "playground-s-11-669d86ee"
}

variable "network_name" {
  default = "mysql-privat"
  type    = string
}

variable "db_name" {
  description = "The name of the SQL Database instance"
  default     = "example-mysql-private"
}

variable "region" {
  description = "The region to create the resources in."
  type        = string
  default     = "ap-south1"
}

variable "zone" {
  description = "The GCP zone to create the sample compute instances in. Must within the region specified in 'var.region'"
  type        = string
  default     = "ap-south1-a"
}
variable "name" {
  description = "Name for the load balancer forwarding rule and prefix for supporting resources."
  type        = string
  default     = "ilb-example"
}

variable "custom_labels" {
  description = "A map of custom labels to apply to the resources. The key is the label name and the value is the label value."
  type        = map(string)
  default     = {}
}
