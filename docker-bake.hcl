
variable "TAG" {
  default = "latest"
}

group "default" {
  targets = ["client", "server"]
}

target "client" {
  dockerfile = "client.Dockerfile"
  context = "."
  platforms = ["linux/amd64", "linux/arm/v7"]
  tags = ["docker.io/tintinho/robocook-client:${TAG}"]
  output = ["type=registry"]
}

target "server" {
  dockerfile = "server.Dockerfile"
  context = "."
  platforms = ["linux/amd64", "linux/arm/v7"]
  tags = ["docker.io/tintinho/robocook-server:${TAG}"]
  output = ["type=registry"]
}