class Mounting
  include Context
  #Mounting.builder
  def self.builder
    self.subclasses.map {|klass| klass.builder}
  end

  class StandardMounting < Mounting
    def self.builder
      select_menu_group(field_class_name, [Framing.builder, Border.builder, Matting.builder])
    end
  end

  class CanvasMounting < Mounting
    def self.builder
      select_menu_group(field_class_name, [Framing.builder, Matting.builder])
    end
  end

  class SericelMounting < Mounting
    def self.builder
      CanvasMounting.builder
    end
  end

  class DepthMounting < Mounting
    def self.builder
      select_menu_group(field_class_name, [Framing.builder, Border.builder, Matting.builder])
    end
  end

  ##############################################################################

  class Framing < Mounting
    def self.builder
      select_field = select_field_group(field_class_name, Option.builder(['framed', 'custom framed']))
      field_set_group(field_class_name, Dimension::FieldGroup.options(Dimension::FieldGroup.width_height).prepend(select_field))
    end
  end

  class Border < Mounting
    def self.builder
      field_set_group(field_class_name, Dimension::FieldGroup.options(Dimension::FieldGroup.width_height).prepend(radio_button(field_class_name)))
    end
  end

  class Matting < Mounting
    def self.builder
      field_set_group(field_class_name, Dimension::FieldGroup.options(Dimension::FieldGroup.width_height).prepend(radio_button(field_class_name)))
    end
  end

  class SculptureMounting < Mounting
    def self.builder
      field_set_group(field_class_name, self.subclasses.map{|klass| klass.builder})
    end

    class Case < SculptureMounting
      def self.builder
        options = [Dimension::FieldGroup.width_height_depth, Dimension::FieldGroup.diameter_height].map{|set| Dimension::FieldGroup.builder(set)}
        field_set_group(field_class_name, [radio_button(field_class_name), select_menu_group(build_name([field_class_name, 'dimensions']), options)])
      end
    end

    class Base < SculptureMounting
      def self.builder
        options = [Dimension::FieldGroup.width_height_depth, Dimension::FieldGroup.diameter_height].map{|set| Dimension::FieldGroup.builder(set)}
        field_set_group(field_class_name, [radio_button(field_class_name), select_menu_group(build_name([field_class_name, 'dimensions']), options)])
      end
    end
  end
end

#field_set_group(field_class_name, SelectMenuOption::Depth.builder(field_class_name))
# module SelectMenuOption
#   module Depth
#     def self.builder(field_class_name)
#       options = [Dimension::FieldGroup.width_height_depth, Dimension::FieldGroup.diameter_height].map{|set| Dimension::FieldGroup.builder(set)}
#       select_menu = select_menu_group("#{field_class_name} dimensions", options)
#       [radio_button(field_class_name), select_menu]
#     end
#   end
# end
