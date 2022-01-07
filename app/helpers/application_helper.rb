module ApplicationHelper

  def boot_classes(element, *html_classes)
    boot_elements[element].concat(html_classes).join(' ')
  end

  def caret_toggle(i, body, context)
    if i == 0 && (body.blank? || context=='body')
      disable_btn(body)
    elsif i == 0
      (fa_icon "caret-right")
    end
  end

  def boot_elements
    {
      submit: %w[btn btn-sm badge form-control submit-btn],
      caret: %w[caret-toggle btn btn-sm bg-transparent border-0],
      btn_nav: %w[slide-toggle btn btn-sm bg-transparent border-0],
      title_toggle: %w[btn btn-sm kind-label bg-gray-c border border-gray-b rounded-left-border-md border-right-0 text-info font-weight-light ml-0 px-0 toggle-view],
      label: %w[kind-label bg-gray-c border border-gray-b rounded-left-border-md border-right-0 text-info fs-xs font-weight-light pt-2 pl-1 pr-0],
      input: %w[form-control bg-gray-c border-gray-b rounded-right-border-md border-left-0 pl-0],
      search_label: %w[fs-xs font-weight-light text-secondary pt-2 pr-1 search-label],
      reset_btn: %w[btn btn-sm bg-gray-d border-light-gray rounded-left-border border-right-0 text-sm font-weight-light],
      search_input: %w[form-control bg-gray-d border-light-gray rounded-right-border border-left-0]
    }
  end

  def included_inputs(inputs, *set)
    inputs.select{|input| set.include?(input['input_name'])}
  end

  def rejected_inputs(inputs, *set)
    inputs.select{|input| set.exclude?(input['input_name'])}
  end

  ##############################################################################

  def dom_ref(*tags)
    tags.map{|tag| format_ref(tag)}.join("-")
  end

  def format_ref(tag)
    tag.respond_to?(:id) ? [obj_name(tag), tag.id].join("-") : tag.to_s
  end

  def obj_name(obj)
    obj.class.name.underscore
  end

end

# def dom_ref(*tags, lev: :type)
#   tags.map{|tag| format_ref(tag, lev)}.join("-")
# end

# def format_ref(tag, lev)
#   if tag.class == Symbol
#     tag.to_s
#   elsif tag.respond_to?(:id)
#     [tag.class.name.underscore, tag.id].join("-")
#   end
# end

# def dom_tag(obj, *tags)
#   tags.map{|tag| tag.to_s}.prepend(format_obj(obj)).join("-")
# end
#
# def fk_id(word)
#   [word.singularize, 'id'].join("_")
# end

# def format_obj(obj)
#   [obj.class.name.underscore, obj.id].join("-")
# end
#
# def reject_words(words, reject_set)
#   words.split(" ").reject{|word| reject_set.include?(word)}.join(" ")
# end
#
# def delim_format(words:, join_delim: ' ', split_delims: [])
#   return words if split_delims.none?
#   split_delims.each do |delim|
#     words = words.split(delim).join(join_delim)
#   end
#   words
# end

##############################################################################

# def css_opt(k, f_name, css_name)
#   "#{css_name}" if k==f_name
# end

# def hattr_inputs(inputs, set, cond=:exclude?)
#   inputs.select{|input| set.public_send(cond).(input['input_name'])}
# end
