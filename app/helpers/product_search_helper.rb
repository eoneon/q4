module ProductSearchHelper

  def search_input_options(name, opts)
    opts.map{|opt| [opt, opt]} #.prepend(["-- #{name.sub('_search','')} --", ""])
  end

  def edit_name(name)
    name = [['Standard',''], ['On ', 'on '], ['One Of A Kind', 'One-of-a-Kind'], ['Of One', ' 1/1']].each_with_object(name) do |word_set|
      name.sub!(word_set[0], word_set[1])
    end
  end

  def active_btn(id, fk_id)
    'active' if id == fk_id
  end

  def split_join(snake_word, delim='_')
    snake_word.split(delim).join(' ')
  end

end
