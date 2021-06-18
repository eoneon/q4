class LimitedEdition
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable

  def self.attrs
    {kind: 2, type: 1, f_name: -1}
  end

  class SelectField < LimitedEdition

    class Numbering < SelectField
      def self.editions(edition_type)
        set = [nil, 'AP', 'EA', 'CP', 'GP', 'PP', 'IP', 'HC', 'TC'].each_with_object([]) do |edition, set|
          next if edition_type == 'Edition' && edition.nil?
          set.append(build_edition(edition, edition_type).join(' '))
        end
      end

      def self.build_edition(edition, edition_type)
        if edition_type == 'Edition'
          ['from', indefinite_article(edition), edition_type]
        else
          [edition, edition_type].compact
        end
      end

      class Numbered < Numbering
        def self.targets
          editions(class_to_cap(const))
        end
      end

      class RomanNumbered < Numbering
        def self.targets
          editions(class_to_cap(const))
        end
      end

      class NumberedOneOfOne < Numbering
        def self.targets
          editions(class_to_cap(const).sub('One Of One', '1/1'))
        end
      end

      class ProofEdition < Numbering
        def self.targets
          editions(class_to_cap(const).sub('Proof', ''))
        end
      end

      class BatchEdition < Numbering
        def self.targets
          ['from an edition of']
        end
      end
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
        def self.assocs
          [:NumberedEdition]
        end

        def self.targets
          build_target_group(%W[Numbered RomanNumbered ProofEdition], 'FieldSet', 'Numbering')
        end
      end
    end
  end
end
