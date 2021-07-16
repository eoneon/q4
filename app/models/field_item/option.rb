class Option < FieldItem

  def self.builder(field_name, kind, tags=nil)
    opt = Option.where(field_name: field_name, kind: kind).first_or_create
    opt.update_tags(tags)
    opt
  end

end
