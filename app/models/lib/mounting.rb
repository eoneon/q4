class Mounting
  include Context

  def self.tags
    tags_hsh(0,-1)
  end

  class StandardMounting < Mounting
    def self.builder
      select_menu(field_class_name, field_kind, [Framing.builder, Border.builder, Matting.builder], tags)
    end
  end

  class CanvasMounting < Mounting
    def self.builder
      select_menu(field_class_name, field_kind, [Framing.builder, Matting.builder], tags)
    end
  end

  class SericelMounting < Mounting
    def self.builder
      CanvasMounting.builder
    end
  end

  class DepthMounting < Mounting
    def self.builder
      select_menu(field_class_name, field_kind, [Framing.builder, Border.builder, Matting.builder], tags)
    end
  end

  ##############################################################################

  class Framing < Mounting
    def self.builder
      select_field = select_field(field_class_name, field_kind, Option.builder(['framed', 'custom framed'], field_kind))
      field_set(field_class_name, field_kind, Dimension::FieldGroup.options(Dimension::FieldGroup.width_height, field_kind).prepend(select_field), tags)
    end
  end

  class Border < Mounting
    def self.builder
      field_set(field_class_name, field_kind, Dimension::FieldGroup.options(Dimension::FieldGroup.width_height, field_kind).prepend(radio_button(field_class_name, field_kind)), tags)
    end
  end

  class Matting < Mounting
    def self.builder
      field_set(field_class_name, field_kind, Dimension::FieldGroup.options(Dimension::FieldGroup.width_height, field_kind).prepend(radio_button(field_class_name, field_kind)), tags)
    end
  end

  class SculptureMounting < Mounting
    def self.builder
      field_set(field_class_name, field_kind, self.subclasses.map{|klass| klass.builder}, tags)
    end

    class Case < SculptureMounting
      def self.builder
        options = [Dimension::FieldGroup.width_height_depth, Dimension::FieldGroup.diameter_height].map{|set| Dimension::FieldGroup.builder(set, field_kind)}
        field_set(field_class_name, field_kind, [radio_button(field_class_name, field_kind), select_menu(build_name([field_class_name, 'dimensions']), field_kind, options)], tags)
      end
    end

    class Base < SculptureMounting
      def self.builder
        options = [Dimension::FieldGroup.width_height_depth, Dimension::FieldGroup.diameter_height].map{|set| Dimension::FieldGroup.builder(set, field_kind)}
        field_set(field_class_name, field_kind, [radio_button(field_class_name, field_kind), select_menu(build_name([field_class_name, 'dimensions']), field_kind, options)], tags)
      end
    end
  end
end
