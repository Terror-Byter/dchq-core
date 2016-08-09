module Common
  extend ActiveSupport::Concern

  included do
    private
    def generate_token method
      loop do
        token = Devise.friendly_token
        break token unless self.class.send("find_by_#{ method }", token)
      end
    end
  end
end
