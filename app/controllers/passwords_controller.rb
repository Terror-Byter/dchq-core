class PasswordsController < Devise::PasswordsController
  skip_filter :check_available_shops
  layout 'session'
end
