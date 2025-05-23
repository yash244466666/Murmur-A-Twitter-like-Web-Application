Rswag::Api.configure do |c|
  # Specify a root folder where Swagger JSON files are located
  # This is used by the Swagger middleware to serve requests for API descriptions
  c.openapi_root = Rails.root.join('public/api-docs').to_s

  # Ensure swagger files are properly copied
  FileUtils.cp_r(Rails.root.join('swagger/.'), Rails.root.join('public/api-docs/'))

  # Inject a lambda function to alter the returned Swagger prior to serialization
  # The function will have access to the rack env for the current request
  c.swagger_filter = lambda { |swagger, env| swagger['host'] = env['HTTP_HOST'] }
end
