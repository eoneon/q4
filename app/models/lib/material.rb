class Material
  include Context
  #Material::Canvas.builder
  class StandardMaterial < Material
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      SelectMenu.builder(h={field_name: "#{klass_name}-options", options: [Material::Canvas.builder, Material::Paper.builder]})
    end
  end

  class Canvas < Material
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      select_field = Select.field(klass_name, Option.builder(['canvas', 'canvas board', 'textured canvas']))
      options = [select_field, Dimension::FlatDimension.builder, Mounting::StandardMounting.builder]
      FieldSet.builder(f={field_name: klass_name, options: options})
      #FieldSet.builder(f={field_name: klass_name, options: Dimension.builder(Dimension.width_height).prepend(select_field).append(Mounting::StandardMounting.builder)})
    end
  end

  class WrappedCanvas < Material
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      select_field = Select.field(klass_name, Option.builder(['gallery wrapped canvas', 'stretched canvas']))
      FieldSet.builder(f={field_name: klass_name, options: Dimension.builder(Dimension.width_height).prepend(select_field)})
    end
  end

  class Paper < Material
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      select_field = Select.field(klass_name, Option.builder(['paper', 'deckle edge paper', 'rice paper', 'arches paper', 'sommerset paper', 'mother of pearl paper']))
      FieldSet.builder(f={field_name: klass_name, options: Dimension.builder(Dimension.width_height).prepend(select_field).append(Mounting::StandardMounting.builder)})
    end
  end

  class PhotographyPaper < Material
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      select_field = Select.field(klass_name, Option.builder(['paper', 'photography paper', 'archival grade paper']))
      FieldSet.builder(f={field_name: klass_name, options: Dimension.builder(Dimension.width_height).prepend(select_field)})
    end
  end

  class PhotographyPaper < Material
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      select_field = Select.field(klass_name, Option.builder(['paper', 'animation paper']))
      FieldSet.builder(f={field_name: klass_name, options: Dimension.builder(Dimension.width_height).prepend(select_field)})
    end
  end

  class Wood < Material
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      select_field = Select.field(klass_name, Option.builder(['wood', 'wood panel', 'board']))
      FieldSet.builder(f={field_name: klass_name, options: Dimension.builder(Dimension.width_height).prepend(select_field)})
    end
  end

  class WoodBox < Material
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      select_field = Select.field(klass_name, Option.builder(['wood box']))
      FieldSet.builder(f={field_name: klass_name, options: Dimension.builder(Dimension.width_height).prepend(select_field)})
    end
  end

  class Metal < Material
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      select_field = Select.field(klass_name, Option.builder(['metal', 'metal panel', 'aluminum', 'aluminum panel']))
      FieldSet.builder(f={field_name: klass_name, options: Dimension.builder(Dimension.width_height).prepend(select_field)})
    end
  end

  class MetalBox < Material
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      select_field = Select.field(klass_name, Option.builder(['metal box']))
      FieldSet.builder(f={field_name: klass_name, options: Dimension.builder(Dimension.width_height).prepend(select_field)})
    end
  end

  class Acrylic < Material
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      select_field = Select.field(klass_name, Option.builder(['acrylic', 'acrylic panel', 'resin']))
      FieldSet.builder(f={field_name: klass_name, options: Dimension.builder(Dimension.width_height).prepend(select_field)})
    end
  end

  class Sericel < Material
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      select_field = Select.field(klass_name, Option.builder(['sericel', 'sericel with background', 'sericel with lithographic background']))
      FieldSet.builder(f={field_name: klass_name, options: Dimension.builder(Dimension.width_height).prepend(select_field)})
    end
  end

  ##############################################################################

  class SculptureMaterial < Material
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      select_field = Select.field(klass_name, Option.builder(['glass', 'ceramic', 'bronze', 'acrylic', 'lucite', 'pewter', 'mixed media']))
    end
  end

  ##############################################################################

  module Select
    def self.field(klass_name, options)
      SelectField.builder(f={field_name: "#{klass_name}-options", options: options})
    end
  end

  ##############################################################################

  # module Dimension
  #   def self.builder(dimension_set)
  #     dimension_set.map {|field_name| NumberField.builder(f={field_name: field_name})}
  #   end
  #
  #   def self.width_height
  #     %w[width height]
  #   end
  #
  #   def self.image_diamter
  #     %w[image_diamter]
  #   end
  #
  #   def self.width_height_depth
  #     %w[width height depth]
  #   end
  #
  #   def self.width_height_depth_weight
  #     %w[width height depth weight]
  #   end
  #
  #   def self.diamater_height_weight
  #     %w[diamater height weight]
  #   end
  #
  #   def self.diamater_weight
  #     %w[diamater weight]
  #   end
  # end
end
