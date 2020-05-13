class Numbering
  include Context

  def self.builder
    SelectMenu.builder(field_name: decamelize(self.slice_class(0)), options: self.subclasses.map {|klass| klass.builder})
  end

  class Numbered < Numbering
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      f={field_name: klass_name, options: [Edition.select_field(klass_name), NumberField.builder(f={field_name:'edition_number'}), NumberField.builder(f={field_name:'edition_size'})]}
      FieldSet.builder(f)
    end
  end

  class RomanNumbered < Numbering
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      f={field_name: klass_name, options: [Edition.select_field(klass_name), TextField.builder(f={field_name:'edition_number'}), TextField.builder(f={field_name:'edition_size'})]}
      FieldSet.builder(f)
    end
  end

  class JapaneseNumbered < Numbering
    def self.builder
      Edition.select_field(decamelize(self.slice_class(-1)))
    end
  end

  class ProofEdition < Numbering
    def self.builder
      Edition.select_field(decamelize(self.slice_class(-1)))
    end
  end

  ##############################################################################

  module Edition
    def self.select_field(klass_name)
      SelectField.builder(f={field_name: select_field_name(klass_name), options: Option.builder(Proof.build_option_names(klass_name))})
    end

    def self.select_field_name(klass_name)
      "#{klass_name.sub('numbered', 'numbering')}-options"
    end
  end

  module Proof
    def self.set
      ['', 'AP', 'EA', 'CP', 'GP', 'PP', 'IP', 'HC', 'TC']
    end

    def self.build_option_names(klass_name)
      if klass_name == 'proof edition'
        set.reject {|i| i.blank?}.map {|proof| "from #{format_vowel('a', proof)} #{proof} edition"}
      else
        set.map{|opt| [opt, klass_name].reject {|i| i.nil?}.join(" ").strip}
      end
    end

    def self.format_vowel(vowel, word)
      if %w[a e i o u].include?(word.first.downcase) && word.split('-').first != 'one'
        'an'
      else
        'a'
      end
    end
  end
end
