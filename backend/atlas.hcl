variable "database_url" {
  type    = string
  default = "postgres://bartering:bartering@localhost:5432/bartering_dev?sslmode=disable"
}

env "local" {
  src = "file://schema.hcl"
  url = var.database_url
  dev = "docker://postgres/17/dev?search_path=public"

  migration {
    dir = "file://migrations"
  }
}
