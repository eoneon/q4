module ProductSearchHelper
  def search_input_options(field_name, opt_set)
    opt_set.map{|opt_hsh| [opt_hsh[:opt_text], opt_hsh[:opt_value]]}.prepend(["-- select #{split_join(field_name, '_')}--", "all"])
  end

  def split_join(snake_word, delim=' ')
    snake_word.split(delim).join(' ')
  end
end
