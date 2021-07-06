class Category
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  # h = Category.build_and_store(:targets, {})
  def self.attrs
    {kind: 0, type: 1, subkind: 2, f_name: -1}
  end

  class RadioButton < Category
    class Original < RadioButton #2
      def self.admin_attrs
        {art_type: 'Original', art_category: 'Original Painting'}
      end

      def self.name_values(args)
        name = name_from_class(args[:f_name], %w[of a], [['Standard', ''], ['One of a Kind', 'One-of-a-Kind'], ['of One', ' 1/1']])
        {category_search: args[:f_name], product_name: name, item_name: name}
      end

      class StandardOriginal < Original #3
        def self.targets
        end
      end

      class OneOfAKind < Original
        def self.targets
        end
      end
    end

    class ReproductionPrint < RadioButton
      def self.admin_attrs
        {art_type: 'Print', art_category: 'Limited Edition'}
      end

      def self.name_values(args)
        {category_search: args[:f_name]}
      end

      def self.targets
      end
    end

    class Sculpture < RadioButton
      def self.admin_attrs
        {art_type: 'Sculpture/Glass', item_category: 'Sculpture'}
      end

      def self.name_values(args)
        {category_search: args[:f_name].sub('Standard', '')}
      end

      class StandardSculpture < Sculpture
        def self.targets
        end
      end

      class HandBlownGlass < Sculpture
        def self.admin_attrs
          {item_type: 'Sculpture', item_category: 'Hand Blown Glass'}
        end

        class StandardHandBlownGlass < HandBlownGlass
          def self.targets
          end
        end

        class GartnerBladeGlass < HandBlownGlass
          def self.targets
          end
        end
      end

    end
  end

  class FieldSet < Category
    class Original < FieldSet
      def self.admin_attrs
        {art_type: 'Original', art_category: 'Original Painting'}
      end

      def self.name_values(args)
        name = name_from_class(args[:f_name], %w[of a], [['One of a Kind', 'One-of-a-Kind'], ['of One', ' 1/1']])
        {category_search: args[:f_name], product_name: name, item_name: name}
      end

      class OneOfAKindOfOne < Original
        def self.targets
          [%W[SelectField Numbering SingleEdition]]
        end
      end

      class UniqueVariation < Original
        def self.targets
          [%W[SelectMenu Numbering NumberingType]]
        end
      end
    end

    class LimitedEdition < FieldSet
      def self.admin_attrs
        {art_type: 'Limited Edition', art_category: 'Limited Edition'}
      end

      def self.name_values
        {category_search: 'LimitedEdition', product_name: 'Limited Edition'}
      end

      def self.targets
        [%W[SelectMenu Numbering NumberingType]]
      end
    end

    class LimitedEditionSculpture < FieldSet
      def self.admin_attrs
        {art_type: 'Sculpture/Glass', item_category: 'Sculpture'}
      end

      def self.name_values
        {category_search: 'Sculpture', product_name: 'Limited Edition'} #fname
      end

      def self.targets
        [%W[SelectMenu Numbering NumberingType]]
      end
    end

  end
end
