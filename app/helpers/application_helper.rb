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

  # def label_tag(obj)
  #   obj.type
  # end
end
