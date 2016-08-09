module Stores
  class ScubaTribe < ActiveRecord::Base
    has_paper_trail

    belongs_to :store

    attr_accessible :api_key, :user_id
  end
end
