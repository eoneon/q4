class Detail
  include Context

  def self.field_kind
    klass_name.underscore
  end

  class Disclaimer < Detail
    def self.builder
      field_set(field_name, field_kind, [select_field(field_name+' level', field_kind, options), text_area(field_name+' text', field_kind)])
    end

    def self.options
      Option.builder(%w[warning danger], field_kind)
    end
  end

  class MediaSuffix < Detail
    def self.builder
      text_area(field_name, field_kind)
    end
  end
end
