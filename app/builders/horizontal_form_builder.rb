class HorizontalFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, :tag, :image_tag, to: :@template
  delegate :current_locality, to: :"@template.controller"

  %w[text_field text_area password_field file_field hidden_field
     datetime_select text_area grouped_collection_select
     phone_field email_field].each do |method_name|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def h_#{method_name}(name, *args)
        options     = args.extract_options!
        label_text  = options.delete(:label)
        group_class = options.delete(:group_class)
        if object.errors[name].any?
          options[:class] = "\#{options[:class]} error"
          options[:data] ||= Hash.new
          options[:data][:error] = object.errors[name].join(', ')
        end
        args << options
        content_tag :div, class: "control-group" << " \#{group_class}" do
          label(name, label_text, class: 'control-label') +
            content_tag(:div, class: 'controls') { #{method_name}(name, *args) }
        end
      end
    RUBY
  end

  def h_select(name, choices, options={}, html_options={})
    label_text  = options.delete(:label)
    group_class = html_options.delete(:group_class)
    if object.errors[name].any?
      html_options[:class] = "#{options[:class]} error"
      html_options[:data] ||= Hash.new
      html_options[:data][:error] = object.errors[name].join(', ')
    end
    if name.to_s =~ /page_id\z/
      options.merge!(include_blank: true)
      choices       = Cms::Page.select_for(current_locality)
      base_name     = name.to_s.gsub(/_page_id\z/,'')
      external_url  = "#{base_name}_external_url"
      if object.respond_to?(external_url)
        choices.insert 0, ["[External URL]", -1]
        label_text  = base_name.humanize
        tags        = select(name, choices, options, html_options)
        tags << text_field(external_url, placeholder: 'https://example.com')
      else
        tags = select(name, choices, options, html_options)
      end
    else
      tags = select(name, choices, options, html_options)
    end
    content_tag :div, class: "control-group" << " #{group_class}" do
      label(name, label_text, class: 'control-label') +
        content_tag(:div, class: 'controls') { tags }
    end
  end

  def h_check_box(name, *args)
    options = args.extract_options!
    options[:label] ||= name.to_s.humanize
    if object.errors[name].any?
      options[:class] = "#{options[:class]} error"
      options[:data] ||= Hash.new
      options[:data][:error] = object.errors[name].join(', ')
    end
    content_tag :div, class: 'control-group' do
      content_tag :div, class: 'controls' do
        label name, options[:label], class: 'checkbox' do
          check_box(name) + " #{options[:label]}"
        end
      end
    end
  end

  def h_submit(*args)
    content_tag :div, class: 'control-group' do
      content_tag :div, class: 'controls' do
        submit(*args)
      end
    end
  end

  private

  # Private: Filter keys passed to tags.
  #
  def objectify_options(options)
    super.except(:label)
  end
end
