module ApplicationHelper
  def display_flash
    content_tag :div, render_flash, id: 'flash-wrapper'
  end

  def render_flash
    content = String.new.html_safe
    classes = "alert"
    flash.each do |key, value|
      case key
      when :alert   then classes
      when :notice  then classes << " alert-success"
      else               classes << " alert-#{key}"
      end
      content << content_tag(:div, value, class: classes)
    end
    content
  end
  
  def markdown_to_html(to_render)
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      hard_wrap: true, filter_html: true, autolink: true, no_intra_emphasis: true, fenced_code_blocks: true, tables: true)
    @markdown.render(to_render).html_safe
  end

  def markdown_to_plain_text(to_render)
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::PlainText,
      hard_wrap: true, filter_html: true, autolink: true, no_intra_emphasis: true, fenced_code_blocks: true, tables: true)
    @markdown.render(to_render).html_safe
  end
    
  def license_tooltip
    content_tag(:small) do
      content_tag(:center, '<b>Creative Commons Attribution 3.0 License</b><hr />') +
      content_tag(:p, '<span class=\'text-success\'><b>You are free:</b></span>') +
      content_tag(:blockquote, '<b>to Share</b> &mdash; to copy, distribute and transmit the work') +
      content_tag(:blockquote, '<b>to Remix</b> &mdash; to adapt the work commercial use of the work') +
      content_tag(:p, '<span class=\'text-error\'><b>Under the following conditions:</b></span>') +
      content_tag(:blockquote, '<i class=\'icon-refresh\' /> &nbsp; <b>Attribution</b> &mdash; You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work).') +
      content_tag(:p, '<span class=\'text-info\'><b>With the understanding that:</b></span>') +
      content_tag(:blockquote, '<b>Waiver</b> &mdash; Any of the above conditions can be <b><u>waived</u></b> if you get permission from the copyright holder.') +
      content_tag(:blockquote, '<b>Public Domain</b> &mdash; Where the work or any of its elements is in the <b><u>public domain</u></b> under applicable law, that status is in no way affected by the license.') +
      content_tag(:blockquote, '<b>Other Rights</b> &mdash; In no way are any of the following rights affected by the license:') +
      content_tag(:ul) do
        content_tag(:li, 'Your fair dealing or <b><u>fair use</u></b> rights, or other applicable copyright exceptions and limitations;') +
        content_tag(:li, 'The author\'s <b><u>moral</u></b> rights;') +
        content_tag(:li, 'Rights other persons may have either in the work itself or in how the work is used, such as <b><u>publicity</u></b> or privacy rights.')
      end +
      content_tag(:blockquote, '<b>Notice</b> &mdash; For any reuse or distribution, you must make clear to others the license terms of this work. The best way to do this is with a link to this web page.')
    end
  end
end
