module CurrentStoreInfo
  def current_store_info
    Thread.current[:store]
  end

  def self.current_store_info=(store)
    Thread.current[:store] = store
  end
end
