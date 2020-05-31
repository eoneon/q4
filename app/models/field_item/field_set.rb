class FieldSet < FieldItem
  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :check_box_fields, through: :item_groups, source: :target, source_type: "CheckBoxField"
  has_many :radio_buttons, through: :item_groups, source: :target, source_type: "RadioButton"
  has_many :text_fields, through: :item_groups, source: :target, source_type: "TextField"
  has_many :number_fields, through: :item_groups, source: :target, source_type: "NumberField"
  has_many :text_area_fields, through: :item_groups, source: :target, source_type: "TextAreaField"

  # Product.product_categories.each do |h|
  #   scope h[:scope_name], -> {h[:scope]}
  # end

  # FieldSet.filter_search(FieldSet.media_set, 'sub_medium', "standard_painting")
  # FieldSet.submedia_set("standard_painting")
  # FieldSet.filter_tag(set, 'material')
  # FieldSet.filter_tag(set, 'material')
  # FieldSet.search([["sub_kind", "limited_edition"]])
  def self.media_set
    FieldSet.search([["kind", "medium"]])
  end

  def self.submedia_set(v)
    filter_search(media_set, 'sub_medium', v)
  end

  def self.media_tags
    filter_tag(media_set, 'sub_kind')
  end

  def self.submedia_tags
  #  Medium::FSO.sub_media.map{|klass| klass_name.underscore}
    filter_tag(media_set, 'sub_medium')
  end

  def self.filter_tag(set, k)
    set.map{|i| i.tags[k]}.uniq
  end

  def self.builder(f)
    #field_set = FieldSet.where(field_name: f[:field_name], tags: id_tags(f[:tags])).first_or_create
    field_set = FieldSet.where(field_name: f[:field_name]).first_or_create
    update_tags(field_set, f[:tags])
    f[:options].map {|opt| field_set.assoc_unless_included(opt)}
    field_set
  end
end
