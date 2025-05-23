Rswag::Ui.configure do |c|
  # List the Swagger endpoints
  c.swagger_endpoint '/api-docs/v1/swagger.yaml', 'Twitter Clone API V1'

  # Set up UI configuration
  c.config_object = {
    docExpansion: 'none',      # Keep docs collapsed by default
    filter: true,              # Enable filtering
    displayRequestDuration: true,
    deepLinking: true,
    showExtensions: true,
    showCommonExtensions: true
  }
end
