class Option < FieldItem

  # def self.builder(field_name, kind, tags, assoc)
  #   opt = Option.where(field_name: field_name, kind: kind).first_or_create
  #   opt.update_tags(tags)
  #   opt.update_assocs(opt, assoc)
  # end

  def self.builder(field_name, kind, tags)
    opt = Option.where(field_name: field_name, kind: kind).first_or_create
    opt.update_tags(tags)
    opt
  end

end
