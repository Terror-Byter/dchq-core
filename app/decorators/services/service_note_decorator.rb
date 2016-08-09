class Services::ServiceNoteDecorator < Draper::Decorator
  delegate_all

  def creator_full_name
    creator.full_name
  end
end
