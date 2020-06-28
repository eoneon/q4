module ProductSearchHelper
  def search_input_options(field_name, opt_set)
    opt_set.map{|opt_hsh| [opt_hsh[:opt_text], opt_hsh[:opt_value]]}.prepend(["-- select #{split_join(field_name, '_')}--", "all"])
  end

  def radio_option_group(input_name, set=[])
    Product.ordered_types.each do |type|
      set << h={name: input_name, label: format_product_type(type), value: type}
    end
    set
  end

  def format_product_type(type)
    type == 'StandardProduct' ? 'Standard Product' : type
  end

  def split_join(snake_word, delim=' ')
    snake_word.split(delim).join(' ')
  end

  #methods for building dropdown structure
  # def self.build_search_opt(search_key, opt)
  #   h={opt_name: search_key, opt_text: format_text_tag(opt), opt_value: opt}
  # end

  def format_text_tag(tag_value)
    tag_value = [['paper_only', '(paper only)'], ['standard', ''], ['limited_edition', 'ltd ed'], ['one_of_a_kind', 'one-of-a-kind']].map{|set| tag_value.sub(set[0], tag_value[1])}[0]
    tag_value = tag_value.split('_')
    [tag_value[0..-2], tag_value[-1]].join(' ')
  end
end
