class Product < ApplicationRecord
  include STI

  validates :type, :product_name, presence: true
  validates :product_name, uniqueness: true

  has_many :item_groups, as: :origin
  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  has_many :check_box_fields, through: :item_groups, source: :target, source_type: "CheckBoxField"
  has_many :radio_buttons, through: :item_groups, source: :target, source_type: "RadioButton"
  has_many :text_fields, through: :item_groups, source: :target, source_type: "TextField"
  has_many :number_fields, through: :item_groups, source: :target, source_type: "NumberField"
  has_many :text_area_fields, through: :item_groups, source: :target, source_type: "TextAreaField"

  scope :product_group, -> {self.all}

  ##############################################################################

  def field_targets
    scoped_sti_targets_by_type(scope: 'FieldItem', rel: :has_many, reject_set: ['RadioButton'])
  end

  def field_params
    fs, fs_opts, opts = [], [], []
    field_targets.each do |f|
      if f.type == 'SelectField'
        opts << build_param(f)
      elsif f.type == 'FieldSet'
        #field_set_params(f.targets, fs, fs_opts, opts)
        field_set_params(f.targets, fs, fs_opts)
      elsif f.type == 'SelectMenu'
        fs << build_param(f)
      end
    end
    h={'options' => opts.to_h, 'field_sets' => fs.to_h.merge!(hsh={'options' => fs_opts.to_h})}
    h
  end

  # def field_set_params(fields, fs, fs_opts, opts)
  #   fields.each do |f|
  #     if f.type == 'SelectField' && f.kind != 'material'
  #       fs_opts << build_param(f)
  #     elsif f.type == 'SelectField' && f.kind == 'material'
  #       opts << build_param(f)
  #     elsif f.type == 'SelectMenu'
  #       fs << build_param(f)
  #     end
  #   end
  # end

  def field_set_params(fields, fs, fs_opts)
    fields.each do |f|
      if f.type == 'SelectField'
        fs_opts << build_param(f)
      elsif f.type == 'SelectMenu'
        fs << build_param(f)
      end
    end
  end

  def build_param(f)
    [f.kind+'_id', nil]
  end

  # def assign_or_merge(h, hsh, k)
  #   h.empty? ? h = hsh : h.merge(hsh)
  #   h
  # end
  #
  # def material_field_set
  #   field_sets.find_by(kind: 'material')
  # end
  #
  # def numbering_field_set
  #   select_menus.find_by(kind: 'numbering')
  # end
  #
  # def material_fields
  #   material_field_set.targets if material_field_set
  # end
  #
  # def numbering_fields
  #   numbering_field_set.targets if numbering_field_set
  # end

  ##############################################################################

  def self.tag_search_field_group(search_keys:, products: product_group, h: {})
    search_keys.map{|search_key| h[:"#{search_key}"] = search_values(products, search_key)}
    h
  end

  def self.valid_search_keys(products=product_group)
    filter_keys.keep_if {|k| uniq_tag_keys_from_set(products).include?(k)}
  end

  def self.uniq_tag_keys_from_set(products=product_group)
    products.pluck(:tags).map{|tags| tags.keys}.flatten.uniq
  end

  def self.search_values(products, search_key)
    products.map{|product| product.tags[search_key]}.uniq.compact
  end

  ##############################################################################

  def self.search_inputs(search_set, selected_hsh, scope, inputs=[])
    hidden_inputs = hidden_inputs(search_set, selected_hsh)
    hidden_inputs.map{|h| h[:input_name]}.each do |input_name|
      inputs << tag_inputs(search_set, input_name)
    end
    h={type: self.to_s, hidden: hidden_inputs, inputs: inputs, selected: set_selected(hidden_inputs, scope)}
  end

  def self.hidden_inputs(search_set, selected_hsh, set=[]) # FieldSet.hidden_inputs(FieldSet.media_set, h={"hidden"=>{"medium_category"=>"4", "medium"=>"0", "material"=>"0", "hand_pulled"=>"0"}})
    search_keys(search_set).each do |k|
      set << h={input_name: k, input_value: selected_hsh[k]}
    end
    set.reject {|h| h[:input_value].nil?}
  end
  #
  def self.tag_inputs(search_set, input_name, set=[])
    filter_tag(search_set, input_name).each do |tag|
      set << h={opt_name: input_name, opt_text: format_text_tag(tag), opt_value: tag}
    end
    set
  end

  def self.set_selected(hidden_inputs, scope='product_search')
    hidden_inputs.map {|h| ["##{scope}_#{h[:input_name]}", h[:input_value]]}
  end

  def self.filter_tag(set, k)
    set.map{|i| i.tags[k]}.uniq.compact
  end

  def self.format_text_tag(tag)
    tag = [['paper_only', '(paper only)'], ['standard', ''], ['limited_edition', 'ltd ed'], ['one_of_a_kind', 'one-of-a-kind']].map{|set| tag.sub(set[0], set[1])}[0]
    tag = tag.split('_')
    [tag[0..-2], tag[-1]].join(' ')
  end

  ##############################################################################

  def self.filter_keys
    %w[medium_category medium material]
  end

  #all search keys
  def self.search_keys(search_set)
    search_set.pluck(:tags).map{|tags| tags.keys}.flatten.uniq
  end

  def self.ordered_types
    set=[]
    product_types = Product.file_set[1..-1]
    (1..product_types.count).each do |i|
      type = product_types.detect{|type| type.classify.constantize.type_order == i}
      set << type.classify
    end
    set
  end

  # def self.search_tags(search_set)
  #   tag_set = tag_set(search_set)
  #   %w[medium_category medium material].keep_if {|tag| tag_set.include?(tag)}
  # end
end
