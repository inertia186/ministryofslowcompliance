class PostPresenter < Presents::BasePresenter
  presents :post

  def author_link
    author = post.cached_author
    if author.nil?
      '[REDACTED]'
    else
      link_to author.nickname, search_by_author_path(author)
    end
  end
  
  def title_link
    link_to post.title, post
  end
  
  def relative_created_at
    c = post.created_at
    u = post.body_updated_at
    modified = c.to_i < u.to_i
    content_tag(:abbr, 'title' => "#{c}#{modified ? ', modified %s later' % distance_of_time_in_words(c, u) : ''}") do
      "#{distance_of_time_in_words_to_now c} ago#{modified ? ' *' : ''}"
    end
  end
  
  def formatted_body
    markdown_to_html post.body unless post.body.nil?
  end
end