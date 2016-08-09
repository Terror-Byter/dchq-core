class UserHoliday < ActiveRecord::Base
  attr_accessible :end_date, :start_date, :user_id

  belongs_to :user

  validates :start_date, presence: true, timeliness: { on_or_before: :end_date, type: :date }, unless: ->(p) { p.blank? || p.end_date.blank? }
  validates :end_date, presence: true, timeliness: { type: :date, on_or_after: :start_time },  unless: ->(p) { p.blank? || p.start_date.blank? }
end
