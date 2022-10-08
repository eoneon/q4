class Category
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable

  def self.attrs
    {kind: 0, type: 1, subkind: 2, field_name: -1}
  end

  def self.input_group
    [0, %w[category]]
  end

  class RadioButton < Category
    class Original < RadioButton #2
      def self.admin_attrs
        {art_type: 'Original', art_category: 'Original Painting'}
      end

      def self.name_values(args)
        name = str_edit(str: uncamel(args[:field_name]), swap: ['Standard', '', 'One Of A Kind', 'One-of-a-Kind'])
        {category_search: args[:field_name], product_name: name, tagline: name, body: name.downcase}
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
        {category_search: args[:field_name]}
      end

      def self.targets
      end
    end

    class Sculpture < RadioButton
      def self.admin_attrs
        {art_type: 'Sculpture/Glass', item_category: 'Sculpture'}
      end

      def self.name_values(args)
        {category_search: args[:field_name].sub('Standard', '')}
      end

      class StandardSculpture < Sculpture
        def self.targets
        end
      end

      class HandMadeCeramic < Sculpture
        def self.name_values
          name = 'Hand Made Ceramic'
          {tagline: name, body: name.downcase}
        end

        def self.targets
        end
      end

      class HandBlownGlass < Sculpture
        def self.name_values
          name = 'Hand Blown Glass'
          {tagline: name, body: name.downcase}
        end

        def self.admin_attrs
          {item_type: 'Sculpture', item_category: 'Hand Blown Glass'}
        end

        class StandardHandBlownGlass < HandBlownGlass
          def self.targets
          end
        end

        class GartnerBladeGlass < HandBlownGlass
          def self.name_values
            name = 'Hand Blown Glass Sculpture'
            {tagline: name, body: name.downcase}
          end

          def self.targets
          end
        end
      end

    end
  end

  class SelectField < Category
    class Edition < SelectField
      class EditionType < Edition
        def self.target_tags(f_name)
          {tagline: str_edit(str: f_name, swap: ['SOLD OUT', 'sold out']), body: f_name}
        end

        def self.targets
          ['limited edition', 'sold out limited edition', 'rare limited edition']
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
        name = str_edit(str: uncamel(args[:field_name]), swap: ['One Of A Kind', 'One-of-a-Kind', 'Of One', '1/1'])
        {category_search: args[:field_name], product_name: name, tagline: name, body: name.downcase}
      end

      class OneOfAKindOfOne < Original
        def self.name_values
          {tagline: 'One-of-a-Kind', body: 'one-of-a-kind'}
        end

        def self.targets
          [%W[SelectField Numbering NumberedOneOfOne]]
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
        [%W[SelectField Category EditionType], %W[SelectMenu Numbering NumberingType]]
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
        [%W[SelectField Category EditionType], %W[SelectMenu Numbering NumberingType]]
      end
    end

  end
end
