class Disclaimer
  extend Context
  extend FieldKind

  def self.cascade_build(class_a, class_b, class_c, class_d, store)
    f_kind, f_type, f_name = [class_a, class_b, class_d].map(&:const)
    add_field_group(to_class(f_type), class_d, f_type, f_kind, f_name, store)
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
