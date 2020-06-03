class FieldSet < FieldItem
  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :check_box_fields, through: :item_groups, source: :target, source_type: "CheckBoxField"
  has_many :radio_buttons, through: :item_groups, source: :target, source_type: "RadioButton"
  has_many :text_fields, through: :item_groups, source: :target, source_type: "TextField"
  has_many :number_fields, through: :item_groups, source: :target, source_type: "NumberField"
  has_many :text_area_fields, through: :item_groups, source: :target, source_type: "TextAreaField"

  def self.media_set
    FieldSet.kv_set_search([["kind", "medium"]])
  end

  # FieldSet.tag_form_inputs(FieldSet.media_set, h={"hidden"=>{"medium_category"=>"4", "medium"=>"0", "material"=>"0", "hand_pulled"=>"0"}})
  # FieldSet.tag_inputs(FieldSet.media_set, 'medium_category')
  def self.search_inputs(search_set, tag_param_hsh, inputs=[])
    hidden_inputs = hidden_inputs(search_set, tag_param_hsh)
    hidden_inputs.map{|h| h[:field_name]}.each do |tag_param|
      inputs << tag_inputs(search_set, tag_param)
    end
    h={hidden: hidden_inputs, inputs: inputs}
  end

  def self.tag_inputs(search_set, tag_param, set=[])
    filter_tag(search_set, tag_param).each do |tag|
      set << h={opt_name: tag_param, text: format_text_tag(tag), value: tag}
    end
    set
  end

  def self.hidden_inputs(search_set, tag_param_hsh, set=[]) # FieldSet.hidden_inputs(FieldSet.media_set, h={"hidden"=>{"medium_category"=>"4", "medium"=>"0", "material"=>"0", "hand_pulled"=>"0"}})
    tag_params(search_set).each do |tag_param|
      set << h={field_name: tag_param, field_value: tag_param_hsh[tag_param]}
    end
    set.reject {|h| h[:field_value] == nil}
  end

  def self.tag_params(product_search) # FieldSet.tag_params(@product_search).map{|tag_param| [:"#{tag_param}", 0]}}.to_h
    tag_params = product_search.pluck(:tags).map{|tags| tags.keys}.flatten.uniq
    ["medium_category", "medium", "material", "hand_pulled"].keep_if {|tag| tag_params.include?(tag)}
  end

  def self.format_text_tag(tag) # FieldSet.medium_category_tags.map{|tag| FieldSet.format_text_tag(tag)}
    tag = tag.pluralize.split('_')
    prefix = tag[0..-2]
    prefix = prefix.join('_') == "one_of_a_kind" ? prefix.join('-') : prefix.join(' ') #prefix = tag[0..-2].join('_') == "one_of_a_kind" ? tag[0..-2].join('-') : tag[0..-2].join(' ')
    [prefix, tag[-1]].join(' ')
  end

  def self.filter_tag(set, k)
    set.map{|i| i.tags[k]}.uniq.compact
  end

  def self.builder(f)
    field_set = FieldSet.where(field_name: f[:field_name]).first_or_create
    update_tags(field_set, f[:tags])
    f[:options].map {|opt| field_set.assoc_unless_included(opt)}
    field_set
  end
end
