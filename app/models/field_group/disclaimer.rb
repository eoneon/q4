class Disclaimer
  include ClassContext
  include FieldSeed
  include Hashable

  def self.attrs
    {kind: 0, type: 1, f_name: -1}
  end

  def self.input_group
    [6, %w[disclaimer]]
  end

  def self.config_disclaimer(k, tb_hsh, disclaimer_hsh, input_group, context)
  	config_body(tb_hsh, disclaimer_hsh.values[0])
  end

  def self.config_body(tb_hsh, damage, tag_key='body')
  	tb_hsh[tag_key] = disclaimer(tb_hsh[tag_key], damage)
  end

  # def self.config_disclaimer(k, disclaimer_hsh, input_group, context, d_hsh)
  #   tb_hsh = Item.new.slice_valid_subhsh!(disclaimer_hsh, *Item.new.tb_keys)
  #   d_hsh[k] = config_body(tb_hsh, disclaimer_hsh.values[0])
  # end
  #
  # def self.config_body(tb_hsh, damage, tag_key='body')
  #   tb_hsh[tag_key] = disclaimer(tb_hsh[tag_key], damage)
  #   tb_hsh
  # end

  # def self.config_disclaimer(k, disclaimer_hsh, input_group, context, d_hsh)
  #   if tb_hsh = Item.new.slice_valid_subhsh!(disclaimer_hsh, *Item.new.tb_keys)
  #     if body = config_body(tb_hsh, disclaimer_hsh)
  #       d_hsh.merge!({k=> tb_hsh.merge!({'body'=> body})})
  #       if tb_hsh['tagline']
  #         context[k.to_sym] = true
  #       elsif context[:unsigned]
  #         context[:signature_last] = true
  #       end
  #     end
  #   end
  # end
  #
  # def self.config_body(tb_hsh, damage_hsh, tag_key='body')
  #   disclaimer(tb_hsh[tag_key], damage_hsh.values[0]) if damage_hsh.any?
  # end

  def self.disclaimer(severity, damage)
  	case severity
  		when 'danger'; "** Please note: #{damage} **"
  		when 'warning'; "Please note: #{damage}"
  		when 'notation'; damage
  	end
  end
  # def self.config_disclaimer(k, disclaimer_hsh, d_hsh, input_group)
  #   tb_hsh = slice_valid_subhsh!(disclaimer_hsh, *Item.new.tb_keys)
  #   return unless disclaimer_hsh.any?
  # 	damage, severity = disclaimer_hsh['body'], damage_hsh.values[0]
	# 	d_hsh.merge!({k=> disclaimer_hsh.merge!({'body'=> disclaimer(severity, damage)})})
	# 	context[k.to_sym] = true if severity == 'danger'
  # end

  def self.config_disclaimer_params(k, severity, damage, disclaimer_hsh, context, d_hsh)
  	if damage && severity
  		d_hsh.merge!({k=> disclaimer_hsh.merge!({'body'=> disclaimer(severity, damage)})})
  		context[k.to_sym] = true if severity == 'danger'
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
