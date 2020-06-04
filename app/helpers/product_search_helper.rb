module ProductSearchHelper

  def search_input_options(opt_name, tag_group)
    #tag_group.map{|opt_hsh| [opt_hsh[:text], opt_hsh[:value]]}.prepend(["-- select #{split_join(opt_name, '_')}--", ""])
    tag_group.map{|opt_hsh| [opt_hsh[:text], opt_hsh[:value]]}.prepend(["-- select #{split_join(opt_name, '_')}--", "all"])
  end

  def split_join(snake_word, delim=' ')
    snake_word.split(delim).join(' ')
  end

  # def set_search_set(search_set)
  #   search_set.nil? ? FieldSet.media_set : search_set
  # end

  # def hidden_field_tags(product_search)
  #   FieldSet.tag_params(product_search).map{|tag| [tag, 0]}
  # end
end
