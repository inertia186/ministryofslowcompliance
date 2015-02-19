class EmailAddressValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless value.blank? || value =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      object.errors[attribute] << (options[:message] || 'must be a valid email address')
    end
  end
end

