class Material
  include Context

  class StandardMaterial < Material
    def self.builder
      select_menu(field_class_name, options, search_hsh)
    end

    def self.options
      [Canvas.builder, WrappedCanvas.builder, Paper.builder, Wood.builder, WoodBox.builder, Metal.builder, MetalBox.builder]
    end
  end

  class Canvas < Material
    def self.builder
      select_field = select_field(field_class_name, Option.builder(['canvas', 'canvas board', 'textured canvas']), search_hsh)
      field_set(field_class_name, FieldSetOption::Canvas.builder(select_field), search_hsh)
    end
  end

  class Sericel < Material
    def self.builder
      select_field = select_field(field_class_name, Option.builder(['sericel', 'sericel with background', 'sericel with lithographic background']), search_hsh)
      field_set(field_class_name, FieldSetOption::Sericel.builder(select_field), search_hsh)
    end
  end

  class WrappedCanvas < Material
    def self.builder
      select_field = select_field(field_class_name, Option.builder(['gallery wrapped canvas', 'stretched canvas']), search_hsh)
      field_set(field_class_name, FieldSetOption::WrappedCanvas.builder(select_field), search_hsh)
    end
  end

  class Paper < Material
    def self.builder
      select_field = select_field(field_class_name, Option.builder(['paper', 'deckle edge paper', 'rice paper', 'arches paper', 'sommerset paper', 'mother of pearl paper']), search_hsh)
      field_set(field_class_name, FieldSetOption::Standard.builder(select_field), search_hsh)
    end
  end

  # class PrintMediaPaper < Material
  #   def self.builder
  #     select_field = select_field(field_class_name, Option.builder(['paper', 'deckle edge paper', 'rice paper', 'arches paper', 'sommerset paper', 'mother of pearl paper']), search_hsh)
  #     field_set(field_class_name, FieldSetOption::Standard.builder(select_field), search_hsh)
  #   end
  # end

  class PhotographyPaper < Material
    def self.builder
      select_field = select_field(field_class_name, Option.builder(['paper', 'photography paper', 'archival grade paper']), search_hsh)
      field_set(field_class_name, FieldSetOption::Standard.builder(select_field), search_hsh)
    end
  end

  class AnimationPaper < Material
    def self.builder
      select_field = select_field(field_class_name, Option.builder(['paper', 'animation paper']), search_hsh)
      field_set(field_class_name, FieldSetOption::Standard.builder(select_field), search_hsh)
    end
  end

  class Wood < Material
    def self.builder
      select_field = select_field(field_class_name, Option.builder(['wood', 'wood panel', 'board']), search_hsh)
      field_set(field_class_name, FieldSetOption::Standard.builder(select_field), search_hsh)
    end
  end

  class Metal < Material
    def self.builder
      select_field = select_field(field_class_name, Option.builder(['metal', 'metal panel', 'aluminum', 'aluminum panel']), search_hsh)
      field_set(field_class_name, FieldSetOption::Standard.builder(select_field), search_hsh)
    end
  end

  class WoodBox < Material
    def self.builder
      select_field = select_field(field_class_name, Option.builder(['wood box']), search_hsh)
      field_set(field_class_name, FieldSetOption::Boxed.builder(select_field), search_hsh)
    end
  end

  class MetalBox < Material
    def self.builder
      select_field = select_field(field_class_name, Option.builder(['metal box']), search_hsh)
      field_set(field_class_name, FieldSetOption::Boxed.builder(select_field), search_hsh)
    end
  end

  class Acrylic < Material
    def self.builder
      select_field = select_field(field_class_name, Option.builder(['acrylic', 'acrylic panel', 'resin']), search_hsh)
      field_set(field_class_name, FieldSetOption::Standard.builder(select_field), search_hsh)
    end
  end

  ##############################################################################

  class SculptureMaterial < Material
    def self.builder
      select_field = select_field(field_class_name, Option.builder(['glass', 'ceramic', 'bronze', 'acrylic', 'lucite', 'pewter', 'mixed media']), search_hsh)
      field_set(field_class_name, FieldSetOption::Sculpture.builder(select_field), search_hsh)
    end
  end

  ##############################################################################

  module FieldSetOption
    module Standard
      def self.builder(select_field)
        [select_field, Dimension::FlatDimension.builder, Mounting::StandardMounting.builder]
      end
    end

    module Canvas
      def self.builder(select_field)
        [select_field, Dimension::FlatDimension.builder, Mounting::CanvasMounting.builder]
      end
    end

    module Sericel
      def self.builder(select_field)
        [select_field, Dimension::FlatDimension.builder, Mounting::SericelMounting.builder]
      end
    end

    module WrappedCanvas
      def self.builder(select_field)
        [select_field, Dimension::FieldGroup.builder(Dimension::FieldGroup.width_height)]
      end
    end

    module Boxed
      def self.builder(select_field)
        [select_field, Dimension::FieldGroup.builder(Dimension::FieldGroup.width_height_depth)]
      end
    end

    module Sculpture
      def self.builder(select_field)
        [select_field, Dimension::DepthDimension.builder, Mounting::SculptureMounting.builder]
      end
    end
  end

end
