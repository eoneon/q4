class Mounting
  include Context

  class StandardMounting < Mounting
    def self.builder
      select_menu(field_class_name, [Framing.builder, Border.builder, Matting.builder], search_hsh)
    end
  end

  class CanvasMounting < Mounting
    def self.builder
      select_menu(field_class_name, [Framing.builder, Matting.builder], search_hsh)
    end
  end

  class SericelMounting < Mounting
    def self.builder
      CanvasMounting.builder
    end
  end

  class DepthMounting < Mounting
    def self.builder
      select_menu(field_class_name, [Framing.builder, Border.builder, Matting.builder], search_hsh)
    end
  end

  ##############################################################################

  class Framing < Mounting
    def self.builder
      select_field = select_field(field_class_name, Option.builder(['framed', 'custom framed']))
      field_set(field_class_name, Dimension::FieldGroup.options(Dimension::FieldGroup.width_height).prepend(select_field), search_hsh)
    end
  end

  class Border < Mounting
    def self.builder
      field_set(field_class_name, Dimension::FieldGroup.options(Dimension::FieldGroup.width_height).prepend(radio_button(field_class_name)), search_hsh)
    end
  end

  class Matting < Mounting
    def self.builder
      field_set(field_class_name, Dimension::FieldGroup.options(Dimension::FieldGroup.width_height).prepend(radio_button(field_class_name)), search_hsh)
    end
  end

  class SculptureMounting < Mounting
    def self.builder
      field_set(field_class_name, self.subclasses.map{|klass| klass.builder}, search_hsh)
    end

    class Case < SculptureMounting
      def self.builder
        options = [Dimension::FieldGroup.width_height_depth, Dimension::FieldGroup.diameter_height].map{|set| Dimension::FieldGroup.builder(set)}
        field_set(field_class_name, [radio_button(field_class_name), select_menu(build_name([field_class_name, 'dimensions']), options)], search_hsh)
      end
    end

    class Base < SculptureMounting
      def self.builder
        options = [Dimension::FieldGroup.width_height_depth, Dimension::FieldGroup.diameter_height].map{|set| Dimension::FieldGroup.builder(set)}
        field_set(field_class_name, [radio_button(field_class_name), select_menu(build_name([field_class_name, 'dimensions']), options)], search_hsh)
      end
    end
  end
end
