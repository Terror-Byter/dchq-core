Apipie.configure do |config|
  config.app_name                = "DchqCore"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apipie"
  # were is your API defined?
  config.api_controllers_matcher = File.join(Rails.root, "app", "controllers", "**","*.rb")
  config.validate                = false
  config.api_routes               = Rails.application.routes
  config.copyright               = "&copy; #{Date.today.year}  Dive Centre HQ API"
  config.app_info                = "Dive Centre HQ is the open source platform for dive stores selling products, events and equipment servicing."
end
