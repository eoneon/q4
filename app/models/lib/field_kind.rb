module FieldKind
  # FieldKind.field_group
  def self.field_group
    store = [Medium].each_with_object({}) do |class_a, store|
      class_a.class_cascade(store)
    end
  end

  ##############################################################################
  ##############################################################################
  def add_field_and_assoc_targets(f_class:, f_name:, f_kind:, targets: nil, tags: nil)
    f = add_field(f_class, f_name, f_kind, tags)
    targets.map{|target| f.assoc_unless_included(target)} if targets
    f
  end

  def add_field(f_class, f_name, kind, tags=nil)
    f = f_class.where(field_name: f_name, kind: kind).first_or_create
    update_tags(f, tags)
    f
  end

  def update_tags(f, tags)
    return if tags.blank? || tags.stringify_keys == f.tags
    f.tags = assign_or_merge(f.tags, tags.stringify_keys)
    f.save
  end

  def assign_or_merge(h, h2)
    h.nil? ? h2 : h.merge(h2)
  end

  def merge_field(dig_set, store)
    Item.param_merge(params: store, dig_set: dig_set)
  end
  ##############################################################################
  ##############################################################################
  def dig_and_assoc(f, targets, store)
    dig_fields(targets, store).map{|field| f.assoc_unless_included(field)}
  end

end
