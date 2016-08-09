module CurrentUserInfo
  def current_user_info
    Thread.current[:user]
  end

  def self.current_user_info=(user)
    Thread.current[:user] = user
  end
end
