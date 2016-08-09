module Services
  class ServiceNote < Note
    has_paper_trail

    has_many :attachments, :as => :attachable, :dependent => :destroy
    belongs_to :service

    accepts_nested_attributes_for :attachments, :allow_destroy => true, :reject_if => lambda{|u| u[:data].blank?}

    attr_accessor :notify

    attr_accessible :attachments_attributes, :notify

    after_create :send_note_added_email

    def attachment_links
      return "-" if attachments.blank?
      attachments.map{|u| "<a href='#{u.data.url}'>##{u.id}</a>"}.join(", ")
    end

    private
    def send_note_added_email
      return if notify.eql?("0")
      ServiceMailer.delay.note_added(self)
    end
  end
end
