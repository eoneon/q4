module ApplicationHelper
  def dom_ref(*tags, lev: :type)
    tags.map{|tag| format_ref(tag, lev)}.join("-")
  end

  def format_ref(tag, lev)
    if tag.class == Symbol
      tag.to_s
    elsif tag.respond_to?(:id)
      [tag == :sup ? tag.class.superclass.name.underscore : tag.type.underscore, tag.id].join("-")
    end
  end

  def dom_tag(obj, *tags)
    tags.map{|tag| tag.to_s}.prepend(format_obj(obj)).join("-")
  end

  def fk_id(word)
    [word.singularize, 'id'].join("_")
  end

  def format_obj(obj)
    [obj.class.name.underscore, obj.id].join("-")
  end

  def reject_words(words, reject_set)
    words.split(" ").reject{|word| reject_set.include?(word)}.join(" ")
  end

  def delim_format(words:, join_delim: ' ', split_delims: [])
    return words if split_delims.none?
    split_delims.each do |delim|
      words = words.split(delim).join(join_delim)
    end
    words
  end

  ##############################################################################

end
