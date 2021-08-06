class LimitedEdition
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable

  def self.attrs
    {kind: 2, type: 1, f_name: -1}
  end

  def self.input_group
    [4, %w[numbering]]
  end

  class SelectField < LimitedEdition
    class Numbering < SelectField
      def self.swap_list
        ['Proof', '', 'One Of One', '1/1']
      end

      def self.editions(edition_type)
        set = [nil, 'AP', 'EA', 'CP', 'GP', 'PP', 'IP', 'HC', 'TC'].each_with_object([]) do |edition, set|
          puts "edition_type: #{edition_type}"
          next if edition_type == 'Edition' && edition.nil?
          set.append(build_edition(edition, edition_type).join(' '))
        end
      end

      def self.build_edition(edition, edition_type)
        edition_type == 'Edition' ? ['from', indefinite_article(edition), edition, edition_type] : [edition, edition_type].compact
      end

      def self.target_tags(f_name)
        {tagline: str_edit(str: f_name, skip: %w[from a an of]), body: f_name}
      end

      def self.body(f_name)
        f_name.split(' ').map{|word| word.split('').all?{|char| is_upper?(char)} ? word : word.downcase}.join(' ')
      end

      class Numbered < Numbering
        def self.targets
          editions(const.downcase)
        end
      end

      class RomanNumbered < Numbering
        def self.targets
          editions(str_edit(str: uncamel(const), skip:['Roman'], cntxt: :downcase))
        end
      end

      class NumberedOneOfOne < Numbering
        def self.targets
          editions(str_edit(str: uncamel(const), skip:['Roman'], swap: swap_list, cntxt: :downcase))
        end
      end

      class ProofEdition < Numbering
        def self.targets
          editions(str_edit(str: uncamel(const), swap: swap_list, cntxt: :downcase))
        end
      end

      # class BatchEdition < Numbering
      #   def self.targets
      #     ['from an edition of']
      #   end
      # end
    end
  end

  class FieldSet < LimitedEdition
    class Numbering < FieldSet
      class Numbered < Numbering
        def self.targets
          [%W[SelectField Numbering Numbered], %W[NumberField Numbering Edition], %W[NumberField Numbering EditionSize]]
        end
      end

      class RomanNumbered < Numbering
        def self.targets
          [%W[SelectField Numbering Numbered], %W[TextField Numbering Edition], %W[TextField Numbering Edition]]
        end
      end

      class ProofEdition < Numbering
        def self.targets
          [%W[SelectField Numbering ProofEdition]]
        end
      end
    end
  end

  class SelectMenu < LimitedEdition
    class Numbering < SelectMenu
      class NumberingType < Numbering
        def self.targets
          build_target_group(%W[Numbered RomanNumbered ProofEdition], 'FieldSet', 'Numbering')
        end
      end
    end
  end
end
