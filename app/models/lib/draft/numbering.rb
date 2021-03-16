class Numbering
  include Context

  def self.tags
    tags_hsh(0,-1)
  end

  def self.builder
    select_menu(decamelize(self.slice_class(0)), field_kind, self.subclasses.map {|klass| klass.builder}, tags)
  end

  class Numbered < Numbering
    def self.builder
      select_field = select_field("#{field_name.sub('numbered', 'numbering')}", field_kind, Option.builder(ProofOption.builder(field_name), field_kind), tags)
      field_set(field_name, field_kind, [select_field, number_field('edition_number', field_kind), number_field('edition_size', field_kind)], tags)
    end
  end

  class RomanNumbered < Numbering
    def self.builder
      select_field = select_field("#{field_name.sub('numbered', 'numbering')}", field_kind, Option.builder(ProofOption.builder(field_name), field_kind), tags)
      field_set(field_name, field_kind, [select_field, text_field('edition_number', field_kind), text_field('edition_size', field_kind)], tags)
    end
  end

  class JapaneseNumbered < Numbering
    def self.builder
      select_field("#{field_name.sub('numbered', 'numbering')}", field_kind, Option.builder(ProofOption.builder(field_name), field_kind), tags)
    end
  end

  class ProofEdition < Numbering
    def self.builder
      select_field("#{field_name.sub('numbered', 'numbering')}", field_kind, Option.builder(ProofOption.builder(field_name), field_kind), tags)
    end
  end

  ##############################################################################

  module ProofOption
    def self.builder(field_name)
      if field_name == 'proof edition'
        set.reject {|i| i.blank?}.map {|proof| "from #{Numbering.format_vowel('a', proof)} #{proof} edition"}
      else
        set.map{|opt| [opt, field_name].reject {|i| i.nil?}.join(" ").strip}
      end
    end

    def self.set
      ['', 'AP', 'EA', 'CP', 'GP', 'PP', 'IP', 'HC', 'TC']
    end
  end
end
