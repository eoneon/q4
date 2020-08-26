class Material
  include Context

  def self.tags
    tags_hsh(0,-1)
  end

  class StandardMaterial < Material
    def self.builder
      select_menu(field_class_name, field_kind, options, tags)
    end

    def self.options
      [Canvas, WrappedCanvas, Paper, Wood, WoodBox, Metal, MetalBox]
    end
  end

  class Canvas < Material
    def self.builder
      select_field = select_field(field_class_name, field_kind, Option.builder(['canvas', 'canvas board', 'textured canvas'], field_kind), tags)
      field_set(field_class_name, field_kind, FieldSetOption::Canvas.builder(select_field), tags)
    end
  end

  class Sericel < Material
    def self.builder
      select_field = select_field(field_class_name, field_kind, Option.builder(['sericel', 'sericel with background', 'sericel with lithographic background'], field_kind), tags)
      field_set(field_class_name, field_kind, FieldSetOption::Sericel.builder(select_field), tags)
    end
  end

  class WrappedCanvas < Material
    def self.builder
      select_field = select_field(field_class_name, field_kind, Option.builder(['gallery wrapped canvas', 'stretched canvas'], field_kind), tags)
      field_set(field_class_name, field_kind, FieldSetOption::WrappedCanvas.builder(select_field), tags)
    end
  end

  class Paper < Material
    def self.builder
      select_field = select_field(field_class_name, field_kind, Option.builder(['paper', 'deckle edge paper', 'rice paper', 'arches paper', 'sommerset paper', 'mother of pearl paper'], field_kind), tags)
      field_set(field_class_name, field_kind, FieldSetOption::Standard.builder(select_field), tags)
    end
  end

  class PhotographyPaper < Material
    def self.builder
      select_field = select_field(field_class_name, field_kind, Option.builder(['paper', 'photography paper', 'archival grade paper'], field_kind), tags)
      field_set(field_class_name, field_kind, FieldSetOption::Standard.builder(select_field), tags)
    end
  end

  class AnimationPaper < Material
    def self.builder
      select_field = select_field(field_class_name, field_kind, Option.builder(['paper', 'animation paper'], field_kind), tags)
      field_set(field_class_name, field_kind, FieldSetOption::Standard.builder(select_field), tags)
    end
  end

  class Wood < Material
    def self.builder
      select_field = select_field(field_class_name, field_kind, Option.builder(['wood', 'wood panel', 'board'], field_kind), tags)
      field_set(field_class_name, field_kind, FieldSetOption::Standard.builder(select_field), tags)
    end
  end

  class Metal < Material
    def self.builder
      select_field = select_field(field_class_name, field_kind, Option.builder(['metal', 'metal panel', 'aluminum', 'aluminum panel'], field_kind), tags)
      field_set(field_class_name, field_kind, FieldSetOption::Standard.builder(select_field), tags)
    end
  end

  class WoodBox < Material
    def self.builder
      select_field = select_field(field_class_name, field_kind, Option.builder(['wood box'], field_kind), tags)
      field_set(field_class_name, field_kind, FieldSetOption::Boxed.builder(select_field), tags)
    end
  end

  class MetalBox < Material
    def self.builder
      select_field = select_field(field_class_name, field_kind, Option.builder(['metal box'], field_kind), tags)
      field_set(field_class_name, field_kind, FieldSetOption::Boxed.builder(select_field), tags)
    end
  end

  class Acrylic < Material
    def self.builder
      select_field = select_field(field_class_name, field_kind, Option.builder(['acrylic', 'acrylic panel', 'resin'], field_kind), tags)
      field_set(field_class_name, field_kind, FieldSetOption::Standard.builder(select_field), tags)
    end
  end

  ##############################################################################

  class SculptureMaterial < Material
    def self.builder
      select_field = select_field(field_class_name, field_kind, Option.builder(['glass', 'ceramic', 'bronze', 'acrylic', 'lucite', 'pewter', 'mixed media'], field_kind), tags)
      field_set(field_class_name, field_kind, FieldSetOption::Sculpture.builder(select_field), tags)
    end
  end

  ##############################################################################

  module FieldSetOption
    module Standard
      def self.builder(select_field)
        #[select_field, Dimension::FlatDimension.builder, Mounting::StandardMounting.builder]
        [select_field, Dimension::FlatDimension.builder('material'), Mounting::StandardMounting.builder]
      end
    end

    module Canvas
      def self.builder(select_field)
        #[select_field, Dimension::FlatDimension.builder, Mounting::CanvasMounting.builder]
        [select_field, Dimension::FlatDimension.builder('material'), Mounting::CanvasMounting.builder]
      end
    end

    module Sericel
      def self.builder(select_field)
        #[select_field, Dimension::FlatDimension.builder, Mounting::SericelMounting.builder]
        [select_field, Dimension::FlatDimension.builder('material'), Mounting::SericelMounting.builder]
      end
    end

    module WrappedCanvas
      def self.builder(select_field)
        #[select_field, Dimension::FieldGroup.builder(Dimension::FieldGroup.width_height)]
        [select_field, Dimension::FieldGroup.builder(Dimension::FieldGroup.width_height, 'material')]
      end
    end

    module Boxed
      def self.builder(select_field)
        [select_field, Dimension::FieldGroup.builder(Dimension::FieldGroup.width_height_depth, 'material')]
        #[select_field, Dimension::FieldGroup.builder(Dimension::FieldGroup.width_height_depth)]
      end
    end

    module Sculpture
      def self.builder(select_field)
        #[select_field, Dimension::DepthDimension.builder, Mounting::SculptureMounting.builder]
        [select_field, Dimension::DepthDimension.builder('material'), Mounting::SculptureMounting.builder]
      end
    end
  end

end
