class LimitedEdition
  include ClassContext
  include FieldSeed
  include Hashable

  def self.builder(store)
    args = build_attrs(:attrs)
    add_field_group(to_class(args[:type]), self, args[:type], args[:kind], args[:f_name], store)
  end

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
        def self.targets
          build_target_group(%W[Numbered RomanNumbered ProofEdition], 'FieldSet', 'Numbering')
        end
      end
    end
  end
end

# def self.cascade_build(store)
#   f_type, f_kind, f_name = f_attrs(1, 2, 3)
#   add_field_group(to_class(f_type), self, f_type, f_kind, f_name, store)
# end
