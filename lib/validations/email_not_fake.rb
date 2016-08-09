class EmailNotFakeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    result = EmailVeracity::Address.new(value)
    record.errors[attribute] << "address appears to be fake" unless result.valid?
  end
end
