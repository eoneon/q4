class Mounting
  include Context
  #Mounting::StandardMounting.builder
  class StandardMounting < Mounting
    def self.builder
      SelectMenu.builder(h={field_name: "#{item_name}-options", options: [Mounting::Framed.builder, Mounting::Border.builder, Mounting::Matting.builder]})
    end
  end

  class CanvasMounting < Mounting
    def self.builder
      SelectMenu.builder(h={field_name: "#{item_name}-options", options: [Mounting::Framed.builder, Mounting::Matting.builder]})
    end
  end

  class SericelMounting < Mounting
    def self.builder
      CanvasMounting.builder
    end
  end

  ##############################################################################

  class Framed < Mounting
    def self.builder
      select_field = Select.field(item_name, Option.builder(['framed', 'custom framed']))
      FieldSet.builder(f={field_name: item_name, options: Dimension::Set.options(Dimension::Set.width_height).prepend(select_field)})
    end
  end

  class Border < Mounting
    def self.builder
      select_field = Select.field(item_name, Option.builder(['border']))
      FieldSet.builder(f={field_name: item_name, options: Dimension::Set.options(Dimension::Set.width_height).prepend(select_field)})
    end
  end

  class Matting < Mounting
    def self.builder
      select_field = Select.field(item_name, Option.builder(['matting']))
      FieldSet.builder(f={field_name: item_name, options: Dimension::Set.options(Dimension::Set.width_height).prepend(select_field)})
    end
  end

  ##############################################################################

  module Select
    def self.field(item_name, options)
      SelectField.builder(f={field_name: "#{item_name}-options", options: options})
    end
  end
end
