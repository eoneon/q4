class Dimension
  include Context

  def self.tags
    tags_hsh(0,-1)
  end

  class FlatDimension < Dimension
    def self.builder(origin_kind)
      select_menu(field_name.pluralize, field_kind, [FieldGroup.width_height, FieldGroup.image_diameter].map{|set| FieldGroup.builder(set, origin_kind)}, tags)
    end
  end

  class BoxDimension < Dimension
    def self.builder(origin_kind)
      select_menu(field_name.pluralize, field_kind, [FieldGroup.width_height_depth].map{|set| FieldGroup.builder(set, origin_kind)}, tags)
    end
  end

  class DepthDimension < Dimension
    def self.builder(origin_kind)
      select_menu(field_name.pluralize, field_kind, [FieldGroup.width_height_depth, FieldGroup.width_height_depth_weight, FieldGroup.diameter_height_weight, FieldGroup.diameter_weight].map{|set| FieldGroup.builder(set, origin_kind)}, tags)
    end
  end

  module FieldGroup
    def self.build_name(origin_kind, field_name)
      [origin_kind, field_name].join(" ")
    end

    def self.builder(dimension_set, origin_kind)
      FieldSet.builder(f={field_name: Dimension.arr_to_text(dimension_set), kind: 'dimension', options: options(dimension_set, origin_kind), tags: h={kind: 'dimension'}})
    end

    def self.options(dimension_set, origin_kind)
      dimension_set.map {|field_name| NumberField.builder(f={field_name: build_name(origin_kind, field_name), kind: 'dimension', tags: h={kind: 'dimension'}})} #'material_dimension' + field_name.split('-').join('_')
    end

    def self.width_height
      %w[width height]
    end

    def self.image_diameter
      %w[image-diameter]
    end

    def self.width_height_depth
      %w[width height depth]
    end

    def self.width_height_depth_weight
      %w[width height depth weight]
    end

    def self.diameter_height_weight
      %w[diameter height weight]
    end

    def self.diameter_height
      %w[diameter height]
    end

    def self.diameter_weight
      %w[diameter weight]
    end
  end
end
