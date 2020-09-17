class Detail
  include Context

  def self.field_kind
    klass_name.underscore
  end

  class Disclaimer < Detail
    def self.builder
      field_set(field_name, field_kind, [select_field(field_name+' level', field_kind, options), text_area(field_name+' text', field_kind)])
      #opts = [select_field(field_name+' level', field_kind, options), text_area(field_name+' text', field_kind)]
      #FieldSet.builder(f={field_name: field_name, kind: field_name, options: opts})
    end

    def self.options
      Option.builder(%w[warning danger], field_kind)
    end
  end

  # class BodyPrefix < Detail
  #   def self.builder
  #     FSO.builder(field_name, field_kind, [field_name])
  #   end
  # end
  #
  # class MediaSuffix < Detail
  #   def self.builder
  #     FSO.builder(field_name, field_kind, [field_name])
  #   end
  # end
  #
  # module FSO
  #   def self.builder(field_name, field_kind, text_area_names)
  #     field_set(field_name+' text', field_kind, text_area_names.map{|name| text_area(name, field_kind)})
  #   end
  # end
end
