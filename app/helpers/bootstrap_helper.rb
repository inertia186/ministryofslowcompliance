module BootstrapHelper
  def horizontal_form_for(object, options = {}, &block)
    options[:builder] = HorizontalFormBuilder
    options[:html] ||= {}
    cls = options[:html][:class]
    obj = object.class.to_s.underscore
    cls = [cls.to_s, obj, "form-horizontal"].join(' ').strip
    options[:html][:class] = cls
    form_for(object, options, &block)
  end
end
