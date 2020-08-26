class Option < FieldItem
  #validates :field_name, uniqueness: true

  #revisit: id_tags
  def self.builder(opt_set, kind, tags=nil)
    options = opt_set.map{|opt_name| Option.where(field_name: opt_name, kind: kind, tags: id_tags(tags)).first_or_create}
    unless tags.nil?
      options.map{|option| update_tags(option, tags)}
    end
    options
  end

end
