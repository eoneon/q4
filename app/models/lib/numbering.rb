class Numbering
  include Context

  class Numbered < Numbering
    def self.build_set
      klass_name = decamelize(self.slice_class(-1))
      Edition.builder(klass_name)
      # select_field = SelectField.builder(f={field_name: 'numbering-options', options: Option.builder(Proof.build_option_names(klass_name))})
      # f={field_name: klass_name, options: [select_field, NumberField.builder(f={field_name:'edition_number'}), NumberField.builder(f={field_name:'edition_size'})]}
      # FieldSet.builder(f)
    end
  end

  class RomanNumbered < Numbering
    def self.build_set
    end
  end

  class JapaneseNumbered < Numbering
    def self.build_set
    end
  end

  module Edition
    def self.builder(klass_name)
      select_field = SelectField.builder(f={field_name: select_field_name(klass_name), options: Option.builder(Proof.build_option_names(klass_name))})
      f={field_name: klass_name, options: [select_field, NumberField.builder(f={field_name:'edition_number'}), NumberField.builder(f={field_name:'edition_size'})]}
      FieldSet.builder(f)
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
        set.compact.map {|proof| "from #{format_vowel('a', proof)} #{proof} edition"}
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
