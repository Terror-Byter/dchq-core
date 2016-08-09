module Stores
  class WorkingTime < ActiveRecord::Base
    has_paper_trail

    belongs_to :opened_user, foreign_key: :opened_user_id, class_name: "User"
    belongs_to :closed_user, foreign_key: :closed_user_id, class_name: "User"
    belongs_to :store

    has_many :finance_report, class_name: "Stores::FinanceReport"

    attr_accessible :opened_user, :open_at, :close_at, :closed_user, :opened_user_id

    validates :opened_user, presence:  true
    validates :store, presence: true
    validates :open_at, presence: true, timeliness: {type: :datetime}
    validates :close_at, timeliness: {type: :datetime, after: :open_at}, on: :update
    validates :closed_user, presence: true, on: :update

    default_scope order('id ASC')

    after_update :remove_empty_sales!

    private
    def remove_empty_sales!
      store.sales.empty.destroy_all
    end
  end
end
