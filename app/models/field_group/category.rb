class Category
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable

  def self.builder(store)
    field_group(:targets, store)
  end

  def self.attrs
    {kind: 0, type: 1, subkind: 2, f_name: -1}
  end

  def self.cat_hsh
    {'Original'=> 'Original Painting', 'StandardOriginal'=> 'Original', 'OneOfAKind'=> 'One-of-a-Kind', 'OneOfAKindOfOne'=> 'One-of-a-Kind 1/1', 'UniqueVariation'=> 'Unique Variation', 'ReproductionPrint'=> 'Print', 'LimitedEdition'=> 'Limited Edition', 'Sculpture'=> 'Sculpture/Glass'}
  end

  def self.tag_meths
    [:product_name, :category_search, :art_type, :art_category, :item_category, :item_type]
  end

  class RadioButton < Category

    class Original < RadioButton
      def self.art_type(args)
        args[:subkind]
      end

      def self.art_category(args)
        cat_hsh[args[:subkind]]
      end

      def self.category_search(args)
        args[:f_name]
      end

      def self.product_name(args)
        cat_hsh[args[:f_name]]
      end

      def self.field_value(args)
        cat_hsh[args[:f_name]]
      end

      class StandardOriginal < Original
        def self.group
          [:IsOriginal, :IsOriginalOrOneOfAKind]
        end

        def self.targets
        end
      end

      class OneOfAKind < Original
        def self.group
          [:IsOneOfAKind, :IsOriginalOrOneOfAKind, :IsOneOfAKindOrOneOfAKindOfOne]
        end

        def self.targets
        end
      end

      class OneOfAKindOfOne < Original
        def self.field_value(args)
          cat_hsh['OneOfAKind']
        end

        def self.group
          [:IsOneOfAKindOrOneOfAKindOfOne]
        end

        def self.targets
        end
      end

      class UniqueVariation < Original
        def self.product_name(args)
          cat_hsh[args[:f_name]]
        end

        def self.field_value(args)
          cat_hsh[args[:f_name]]
        end

        def self.category_search(args)
          args[:f_name]
        end

        def self.group
          [:IsUniqueVariation, :IsLimitedEditionOrUniqueVariation, :IsLimitedEditionOrUniqueVariationOrReproduction]
        end

        def self.targets
        end
      end
    end

    class LimitedEdition < RadioButton
      def self.art_type(args)
        cat_hsh[args[:subkind]]
      end

      def self.art_category(args)
        cat_hsh[args[:subkind]]
      end

      def self.product_name(args)
        cat_hsh[args[:subkind]]
      end

      def self.field_value(args)
        cat_hsh[args[:subkind]]
      end

      def self.category_search(args)
        args[:subkind]
      end

      class StandardLimitedEdition < LimitedEdition
        def self.group
          [:IsLimitedEdition, :IsLimitedEditionOrReproduction, :IsLimitedEditionOrUniqueVariation, :IsLimitedEditionOrUniqueVariationOrReproduction]
        end

        def self.targets
        end
      end

    end

    class ReproductionPrint < RadioButton
      def self.art_type(args)
        cat_hsh[args[:subkind]]
      end

      def self.art_category(args)
        cat_hsh['LimitedEdition']
      end

      def self.category_search(args)
        args[:subkind]
      end

      class StandardReproductionPrint < ReproductionPrint
        def self.targets
        end

        def self.group
          [:IsReproduction, :IsLimitedEditionOrReproduction, :IsLimitedEditionOrUniqueVariationOrReproduction]
        end
      end
    end

    class Sculpture < RadioButton
      def self.art_type(args)
        cat_hsh[args[:subkind]]
      end

      def self.item_category(args)
        args[:subkind]
      end

      def self.category_search(args)
        args[:subkind]
      end

      class StandardSculpture < Sculpture
        def self.group
          [:IsSculpture, :IsLimitedEditionSculptureOrSculpture]
        end

        def self.targets
        end
      end

      class LimitedEditionSculpture < Sculpture
        def self.product_name(args)
          cat_hsh['LimitedEdition']
        end

        def self.field_value(args)
          cat_hsh['LimitedEdition']
        end

        def self.category_search(args)
          args[:f_name]
        end

        def self.group
          [:IsLimitedEditionSculpture, :IsLimitedEditionSculptureOrSculpture]
        end

        def self.targets
        end
      end

      class HandBlownGlass < Sculpture
        def self.item_type(args)
          args[:subkind]
        end

        def self.item_category(args)
          cat_hsh[args[:f_name]]
        end

        def self.category_search(args)
          args[:f_name]
        end

        def self.group
          [:IsHandBlownGlass]
        end

        def self.targets
        end
      end

    end
  end
end
