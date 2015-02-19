class CommentPresenter < Presents::BasePresenter
  presents :comment

  def author_link
    author = comment.cached_author
    if author.nil?
      '[REDACTED]'
    else
      link_to author.nickname, search_by_author_path(author)
    end
  end
  
  def relative_created_at
    c = comment.created_at
    u = comment.body_updated_at
    modified = c.to_i < u.to_i
    content_tag(:abbr, 'title' => "#{c}#{modified ? ', modified %s later' % distance_of_time_in_words(c, u) : ''}") do
      "#{distance_of_time_in_words_to_now c} ago#{modified ? ' *' : ''}"
    end
  end
  
  def formatted_body
    markdown_to_html comment.body unless comment.body.nil?
  end
end