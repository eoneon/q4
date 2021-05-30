class Disclaimer
  include ClassContext
  include FieldSeed
  include Hashable

  def self.builder(store)
    args = build_attrs(:attrs)
    add_field_group(to_class(args[:type]), self, args[:type], args[:kind], args[:f_name], store)
  end

  def self.attrs
    {kind: 0, type: 1, f_name: -1}
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

  class FieldSet < Disclaimer

    class Standard < FieldSet
      class StandardDisclaimer < Standard
        def self.targets
          [%W[SelectField Disclaimer Severity], %W[TextAreaField Disclaimer Damage]]
        end
      end
    end
  end
end
