class Numbering
  include Context
  #Numbering.builder
  def self.builder
    select_menu_group(decamelize(self.slice_class(0)), self.subclasses.map {|klass| klass.builder})
  end

  class Numbered < Numbering
    def self.builder
      select_field = select_field_group("#{field_class_name.sub('numbered', 'numbering')}", Option.builder(ProofOption.builder(field_class_name)))
      field_set_group(field_class_name, [select_field, number_field('edition_number'), number_field('edition_size')])
    end
  end

  class RomanNumbered < Numbering
    def self.builder
      select_field = select_field_group("#{field_class_name.sub('numbered', 'numbering')}", Option.builder(ProofOption.builder(field_class_name)))
      field_set_group(field_class_name, [select_field, text_field('edition_number'), text_field('edition_size')])
    end
  end

  class JapaneseNumbered < Numbering
    def self.builder
      select_field_group("#{field_class_name.sub('numbered', 'numbering')}", Option.builder(ProofOption.builder(field_class_name)))
    end
  end

  class ProofEdition < Numbering
    def self.builder
      select_field_group("#{field_class_name.sub('numbered', 'numbering')}", Option.builder(ProofOption.builder(field_class_name)))
    end
  end

  ##############################################################################

  module ProofOption
    def self.builder(field_class_name)
      if field_class_name == 'proof edition'
        set.reject {|i| i.blank?}.map {|proof| "from #{Numbering.format_vowel('a', proof)} #{proof} edition"}
      else
        set.map{|opt| [opt, field_class_name].reject {|i| i.nil?}.join(" ").strip}
      end
    end

    def self.set
      ['', 'AP', 'EA', 'CP', 'GP', 'PP', 'IP', 'HC', 'TC']
    end
  end
end
