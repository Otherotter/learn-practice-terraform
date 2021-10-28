resource "aws_amplify_app" "example" {
  name       = "wireframe "
  repository = "https://github.com/Otherotter/todo_hw2.git"
  # GitHub personal access token
  access_token =  "~/.ssh/id_rsa.pub"

  # The default build_spec added by the Amplify Console for React.
  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        preBuild:
          commands:
            - yarn install
        build:
          commands:
            - yarn run build
      artifacts:
        baseDirectory: build
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  # The default rewrites and redirects added by the Amplify Console.
#   custom_rule {
#     source = "/<*>"
#     status = "404"
#     target = "/index.html"
#   }

  environment_variables = {
    ENV = "test"
  }
}