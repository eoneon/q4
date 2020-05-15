class Dimension
  include Context
  #Dimension::FlatDimension.builder
  class FlatDimension < Dimension
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      SelectMenu.builder(h={field_name: klass_name.pluralize, options: [Set.width_height, Set.image_diameter].map{|set| Set.builder(set)}})
    end
  end

  class BoxDimension < Dimension
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      SelectMenu.builder(h={field_name: klass_name.pluralize, options: [Set.width_height_depth].map{|set| Set.builder(set)}})
    end
  end

  class SculptureDimension < Dimension
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      SelectMenu.builder(h={field_name: klass_name.pluralize, options: [Set.width_height_depth, Set.width_height_depth_weight, Set.diameter_height_weight, Set.diameter_weight].map{|set| Set.builder(set)}})
    end
  end

  module Set
    def self.builder(dimension_set)
      #options = dimension_set.map {|field_name| NumberField.builder(f={field_name: field_name})}
      #FieldSet.builder(f={field_name: arr_to_text(dimension_set), options: options})
      FieldSet.builder(f={field_name: arr_to_text(dimension_set), options: options(dimension_set)})
    end

    def self.options(dimension_set)
      dimension_set.map {|field_name| NumberField.builder(f={field_name: field_name})}
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

    def self.diameter_weight
      %w[diameter weight]
    end

    def self.arr_to_text(arr)
      if arr.length == 2
        arr.join(" & ")
      elsif arr.length > 2
        [arr[0..-3].join(", "), arr[-2, 2].join(" & ")].join(", ")
      else
        arr[0]
      end
    end
  end
end
