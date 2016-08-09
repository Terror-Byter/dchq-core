module Services
  class TimeInterval < ActiveRecord::Base
    has_paper_trail

    belongs_to :service
    belongs_to :user, with_deleted: true

    attr_accessible :starts_at, :ends_at

    validates :service, presence: true
    validates :user, presence: true

    scope :complete, where("ends_at IS NOT NULL")
    scope :in_progress, where(ends_at: nil)

    after_create :update_service_status

    private

    def update_service_status
      service.jump_to_next_step! if service.time_intervals.count < 2
    end

  end
end
