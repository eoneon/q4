class LimitedEdition
  extend Context
  extend FieldKind

  def self.cascade_build(class_a, class_b, class_c, class_d, store)
    f_type, f_kind, f_name = [class_b, class_c, class_d].map(&:const)
    add_field_group(to_class(f_type), class_d, f_type, f_kind, f_name, store)
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

#f = add_field(to_class(f_type), f_name, f_kind)
#f = add_field_and_assoc_targets(f_class: to_class(f_type), f_name: f_name, f_kind: f_kind, targets: class_d.add_targets(f_kind))
#merge_field(Item.dig_set(k: f_name.to_sym, v: f, dig_keys: [f_kind.to_sym, f_type.to_sym]), store)
