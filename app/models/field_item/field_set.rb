class FieldSet < FieldItem

  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :check_box_fields, through: :item_groups, source: :target, source_type: "CheckBoxField"
  has_many :radio_buttons, through: :item_groups, source: :target, source_type: "RadioButton"
  has_many :text_fields, through: :item_groups, source: :target, source_type: "TextField"
  has_many :number_fields, through: :item_groups, source: :target, source_type: "NumberField"
  has_many :text_area_fields, through: :item_groups, source: :target, source_type: "TextAreaField"

  def add_and_assoc_targets(target_group)
    assoc_targets(add_targets(target_group))
  end

  def add_targets(target_group)
    target_group.map{|target_set| to_class(target_set[0]).where(field_name: target_set[2], kind: target_set[1]).first_or_create}
  end

  def assoc_targets(targets)
    targets.map{|target| assoc_unless_included(target)}
  end

  def self.media_set
    FieldSet.kv_set_search([["kind", "medium"]])
  end

  def self.search_inputs(search_set, selected_hsh, scope, inputs=[])
    hidden_inputs = hidden_inputs(search_set, selected_hsh)
    hidden_inputs.map{|h| h[:input_name]}.each do |input_name|
      inputs << tag_inputs(search_set, input_name)
    end
    h={hidden: hidden_inputs, inputs: inputs, selected: set_selected(hidden_inputs, scope)}
  end

  def self.hidden_inputs(search_set, selected_hsh, set=[]) # FieldSet.hidden_inputs(FieldSet.media_set, h={"hidden"=>{"medium_category"=>"4", "medium"=>"0", "material"=>"0", "hand_pulled"=>"0"}})
    search_tags(search_set).each do |tag|
      set << h={input_name: tag, input_value: selected_hsh[tag]}
    end
    set.reject {|h| h[:input_value].nil?} #set.reject {|h| h[:input_value] == nil}
  end

  def self.search_tags(search_set) # FieldSet.search_tags(@product_search).map{|tag_param| [:"#{tag_param}", 0]}}.to_h
    tag_set = tag_set(search_set) #search_set.pluck(:tags).map{|tags| tags.keys}.flatten.uniq
    %w[medium_category medium material].keep_if {|tag| tag_set.include?(tag)}
  end

  def self.filtered_tags(tag_set, filter_set)
    filter_set.keep_if {|tag| tag_set.include?(tag)}
  end

  def self.tag_set(search_set)
    search_set.pluck(:tags).map{|tags| tags.keys}.flatten.uniq
  end

  def self.format_text_tag(tag) # FieldSet.medium_category_tags.map{|tag| FieldSet.format_text_tag(tag)}
    tag = [['paper_only', '(paper only)'], ['standard', ''], ['limited_edition', 'ltd ed'], ['one_of_a_kind', 'one-of-a-kind']].map{|set| tag.sub(set[0], set[1])}[0]
    tag = tag.split('_')
    [tag[0..-2], tag[-1]].join(' ')
  end

  def self.tag_inputs(search_set, input_name, set=[])
    filter_tag(search_set, input_name).each do |tag|
      set << h={opt_name: input_name, opt_text: format_text_tag(tag), opt_value: tag}
    end
    set
  end

  def self.selected(hidden_inputs)
    hidden_inputs.map {|h| ["#product_search_#{h[:input_name]}", h[:input_value]]}
  end

  def self.set_selected(hidden_inputs, scope='product_search')
    hidden_inputs.map {|h| ["##{scope}_#{h[:input_name]}", h[:input_value]]}
  end

  def self.filter_tag(set, k)
    set.map{|i| i.tags[k]}.uniq.compact
  end

  # def self.builder(f)
  #   field_set = FieldSet.where(field_name: f[:field_name], kind: f[:kind]).first_or_create
  #   update_tags(field_set, f[:tags])
  #   f[:options].map {|opt| field_set.assoc_unless_included(opt)}
  #   field_set
  # end
end
