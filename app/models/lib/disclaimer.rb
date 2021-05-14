class Disclaimer
  extend Context
  extend FieldKind

  def self.cascade_build(store)
    f_kind, f_type, f_name = f_attrs(0, 1, 3)
    add_field_group(to_class(f_type), self, f_type, f_kind, f_name, store)
  end

  class SelectField < Disclaimer

    class DisclaimerSeverity < SelectField
      class Severity < DisclaimerSeverity
        def self.targets
          %w[warning danger]
        end
      end
    end
  end

  class TextAreaField < Disclaimer
    class DisclaimerDamage < TextAreaField
      class Damage < DisclaimerDamage
      end
    end
  end
end
