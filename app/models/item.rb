class Item < ApplicationRecord
  include STI

  has_many :item_groups, as: :origin, dependent: :destroy
  has_many :standard_products, through: :item_groups, source: :target, source_type: "StandardProduct"
  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  has_many :artists, through: :item_groups, source: :target, source_type: "Artist"
  belongs_to :invoice, optional: true

  attribute :standard_product
  attribute :product
  attribute :options
  attribute :select_menus

  def field_params
    if product
      product_params = build_options_params(product.field_params)
      product_params = build_field_sets_params(product_params)
      build_field_sets_options_params(product_params)
    end
  end

  def build_options_params(product_params)
    product_params["options"].keys.each do |k|
      product_params["options"][k] = dyno_find_by_kind("options", k)
    end
    product_params
  end

  def build_field_sets_params(product_params)
    product_params["field_sets"].select{|k,v| k != "options"}.keys.each do |k|
      f = dyno_find_by_kind("field_sets", k)
      product_params["field_sets"][k] = f.try(:id)
    end
    product_params
  end

  def build_field_sets_options_params(product_params, tags_hsh={"tags" => nil})
    product_params["field_sets"]["options"].keys.each do |k|
      f = dyno_find_by_kind("options", k)
      product_params["field_sets"]["options"][k] = f.try(:id)
      if fs_fields = build_field_sets_fields_params(f)
        build_tag_params(fs_fields, tags_hsh)
      end
    end
    product_params
  end

  def build_tag_params(fs_fields, tags_hsh)
    fs_fields.each do |f|
      tags_hsh["tags"][f.kind].merge(h={f.name => tags[f.name]})
    end
    tags_hsh
  end

  def build_field_sets_fields_params(f)
    if f && f.targets.any?
      f.targets.select{|ff| tag_fields.include?(ff.type)}
    end
  end

  def dyno_find_by_kind(assoc, k)
    public_send(assoc).find_by(kind: un_id(k))
  end

  def un_id(k)
    k.sub('_id','')
  end

  def tag_fields
    ['NumberField', 'TextField', 'TextAreaField']
  end

  ##############################################################################

  def product
    if product = targets.detect{|target| target.class.method_defined?(:type) && target.base_type == 'Product'}
      product
    end
  end

  def product_id
    product.id if product
  end

  def artist
    artists.first if artists.any?
  end

  def artist_id
    artist.id if artist
  end

  # def field_target_params(h={})
  #   field_targets.each do |field|
  #     h[field_param_key(f)] = field.id
  #   end
  #   h
  # end

  # def field_target_params
  #   f_params, fields = h={field_sets: hsh={options: nil}, options: nil}, field_sets
  #   %w[dimension mounting numbering].each do |kind|
  #     f = fields.find_by(kind: kind)
  #     f_params[:field_sets][kind] = id = f ? f.id : nil
  #   end
  #   f_params
  # end

  def field_target_params
    #f_params={'options' => nil, 'field_sets' => h={'field_sets' => nil, 'options' => nil}}
    f_params={'field_sets' => field_set_params}
    f_params['field_sets']['options'] = h={'options' => field_set_options_params}
    f_params
  end

  def field_set_params
    %w[dimension mounting numbering].map{|k| [k, field_sets.find_by(kind: k)]}.to_h
  end

  def field_set_options_params
    %w[dimension mounting numbering].map{|k| [k, options.find_by(kind: k)]}.to_h
  end

  # def options_params
  #   %w[dimension mounting numbering].map{|k| [k, options.find_by(kind: k)]}.to_h
  # end

  def field_targets
    scoped_sti_targets_by_type(scope: 'FieldItem', rel: :has_many)
  end

  def field_param_key(f)
    [field.kind, field.type.underscore].join('_')
  end

end
