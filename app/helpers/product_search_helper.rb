module ProductSearchHelper

  # def search_input_options(name, opts)
  #   opts.map{|opt| [PRD.format_name(edit_name(PRD.class_to_cap(opt))), opt]}.prepend(["-- select #{split_join(name, '_')}--", ""])
  # end

  def search_input_options(name, opts)
    opts.map{|opt| [opt, opt]}.prepend(["-- select #{split_join(name, '_')}--", ""])
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

# def build_inputs(field_name, opt_set)
#   opt_set.map{|opt_hsh| [opt_hsh[:opt_text], opt_hsh[:opt_value]]}.prepend(["-- select #{split_join(field_name, '_')}--", "all"])
# end

# def format_text_tag(tag_value)
#   tag_value = [['paper_only', '(paper only)'], ['standard', ''], ['limited_edition', 'ltd ed'], ['one_of_a_kind', 'one-of-a-kind']].map{|set| tag_value.sub(set[0], tag_value[1])}[0]
#   tag_value = tag_value.split('_')
#   [tag_value[0..-2], tag_value[-1]].join(' ')
# end
# def radio_option_group(input_name, checked, set=[])
#   Product.ordered_types.each do |type|
#     set << h={name: input_name, label: format_product_type(type), value: type, checked: checked_type(type, checked)}
#   end
#   set
# end
#
# def checked_type(type, checked)
#   if type==checked
#     true
#   else
#     false
#   end
# end
