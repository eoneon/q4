class Disclaimer
  include ClassContext
  include FieldSeed
  include Hashable

  def self.attrs
    {kind: 0, type: 1, field_name: -1}
  end

  def self.input_group
    [6, %w[disclaimer]]
  end

  def self.config_disclaimer(k, tb_hsh, disclaimer_hsh, input_group, context)
    config_body(tb_hsh, disclaimer_hsh.values[0]) if tb_hsh.any? && disclaimer_hsh.any?
  end

  def self.config_body(tb_hsh, damage, tag_key='body')
  	tb_hsh[tag_key] = disclaimer(tb_hsh[tag_key], damage)
    tb_hsh
  end

  def self.disclaimer(severity, damage)
  	case severity
  		when 'danger'; "** Please note: #{damage} **"
  		when 'warning'; "Please note: #{damage}"
  		when 'notation'; damage
  	end
  end

  class SelectField < Disclaimer
    def self.target_tags(f_name)
      {tagline: ('(Disclaimer)' if f_name == 'danger'), body: f_name}
    end

    class DisclaimerSeverity < SelectField
      class Severity < DisclaimerSeverity
        def self.targets
          %w[notation warning danger]
        end
      end
    end
  end

  class TextAreaField < Disclaimer
    class DisclaimerDamage < TextAreaField
      class Damage < DisclaimerDamage
        def self.targets
        end
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
