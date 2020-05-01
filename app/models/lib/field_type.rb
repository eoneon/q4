class FieldType
  def self.attrs_hsh(name, f_set=[])
    h={attrs: {type: klass_name, field_name: f_name(klass_name, name)}, f_set: f_set}
  end

  def self.f_name(klass_name, name)
    if name_suffix = name_suffix(klass_name)
      [name, name_suffix].join("-")
    else
      name
    end
  end

  def self.name_suffix(klass_name)
    if klass_name == 'FieldSet'
      'field-set'
    elsif klass_name == 'SelectField'
      'type'
    end
  end

  module FieldSet
    def self.f_hsh(name, f_set)
      attrs_hsh(name, FieldSetFields.f_set(f_set))
    end
    #f_set: [SelectField.f_hsh(name, f_set), Properties::NumberField.f_hsh(name1), Properties::NumberField.f_hsh(name2)]
    module FieldSetFields
      def self.f_set(f_set)
        f_set.map{|f_subset| f_subset}
      end
    end

  end

  module SelectField
    def self.f_hsh(name, f_set)
      attrs_hsh(name, Option.f_set(f_set))
    end
  end

  module RadioButton
    def self.f_hsh(name, f_set)
      attrs_hsh(name, Option.f_set(f_set))
    end
  end

  module Option
    def self.f_set(f_set)
      f_set.map {|f_name| attrs_hsh(f_name)}
    end
  end

  module Properties
    module NumberField
      def self.f_hsh(name)
        attrs_hsh(name)
      end
    end

    module TextField
      def self.f_hsh(name)
        attrs_hsh(name)
      end
    end

    module TextAreaField
      def self.f_hsh(name)
        attrs_hsh(name)
      end
    end
  end
end

  #mix item_fields and product_items #########################################
  # module FieldGroup
  #   def self.f_hsh(name, f_set)
  #     attrs_hsh(name, FieldSetFields.f_set(f_set))
  #   end
  #   #f_set: [SelectField.f_hsh(name, f_set), Properties::NumberField.f_hsh(name1), Properties::NumberField.f_hsh(name2)]
  #   module FieldSetFields
  #     def self.f_set(f_set)
  #       f_set.map{|f_subset| f_subset}
  #     end
  #   end
  #
  # end
