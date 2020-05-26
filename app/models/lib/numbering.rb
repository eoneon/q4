class Numbering
  include Context

  def self.tags
    tags_hsh(0,-1)
  end

  def self.builder
    select_menu(decamelize(self.slice_class(0)), self.subclasses.map {|klass| klass.builder}, tags)
  end

  class Numbered < Numbering
    def self.builder
      select_field = select_field("#{field_class_name.sub('numbered', 'numbering')}", Option.builder(ProofOption.builder(field_class_name)), tags)
      field_set(field_class_name, [select_field, number_field('edition_number'), number_field('edition_size')], tags)
    end
  end

  class RomanNumbered < Numbering
    def self.builder
      select_field = select_field("#{field_class_name.sub('numbered', 'numbering')}", Option.builder(ProofOption.builder(field_class_name)), tags)
      field_set(field_class_name, [select_field, text_field('edition_number'), text_field('edition_size')], tags)
    end
  end

  class JapaneseNumbered < Numbering
    def self.builder
      select_field("#{field_class_name.sub('numbered', 'numbering')}", Option.builder(ProofOption.builder(field_class_name)), tags)
    end
  end

  class ProofEdition < Numbering
    def self.builder
      select_field("#{field_class_name.sub('numbered', 'numbering')}", Option.builder(ProofOption.builder(field_class_name)), tags)
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
