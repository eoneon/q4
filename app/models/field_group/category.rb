class Category
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable

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
        def self.assocs
          [:IsOriginal, :IsOriginalOrOneOfAKind]
        end

        def self.targets
        end
      end

      class OneOfAKind < Original
        def self.assocs
          [:IsOneOfAKind, :IsOriginalOrOneOfAKind, :IsOneOfAKindOrOneOfAKindOfOne]
        end

        def self.targets
        end
      end

      class OneOfAKindOfOne < Original
        def self.assocs
          [:IsOneOfAKindOfOne, :IsOneOfAKindOrOneOfAKindOfOne]
        end

        def self.targets
        end
      end

      class UniqueVariation < Original
        def self.assocs
          [:IsUniqueVariation, :IsLimitedEditionOrUniqueVariation, :IsLimitedEditionOrUniqueVariationOrReproduction]
        end

        def self.targets
        end
      end
    end

    class LimitedEdition < RadioButton
      def self.admin_attrs
        {art_type: 'Limited Edition', art_category: 'Limited Edition'}
      end

      def self.name_values(args)
        {category_search: 'LimitedEdition', product_name: 'Limited Edition', item_name: 'Limited Edition'}
      end

      def self.assocs
        [:IsLimitedEdition, :IsLimitedEditionOrReproduction, :IsLimitedEditionOrUniqueVariation, :IsLimitedEditionOrUniqueVariationOrReproduction]
      end

      def self.targets
      end
    end

    class ReproductionPrint < RadioButton
      def self.admin_attrs
        {art_type: 'Print', art_category: 'Limited Edition'}
      end

      def self.name_values(args)
        {category_search: args[:f_name]}
      end

      def self.assocs
        [:IsReproduction, :IsLimitedEditionOrReproduction, :IsLimitedEditionOrUniqueVariationOrReproduction]
      end

      def self.targets
      end
    end

    class Sculpture < RadioButton
      def self.admin_attrs
        {art_type: 'Sculpture/Glass', item_category: 'Sculpture'}
      end

      def self.name_values(args)
        {category_search: args[:subkind]} #fname
      end

      class StandardSculpture < Sculpture
        def self.assocs
          [:IsSculpture, :IsLimitedEditionSculptureOrSculpture]
        end

        def self.targets
        end
      end

      class LimitedEditionSculpture < Sculpture
        def self.name_values(args)
          {product_name: 'Limited Edition', item_name: 'Limited Edition'}
        end

        def self.assocs
          [:IsLimitedEditionSculpture, :IsLimitedEditionSculptureOrSculpture]
        end

        def self.targets
        end
      end

      class HandBlownGlass < Sculpture
        def self.attrs
          {subkind: -1}
        end

        def self.admin_attrs
          {item_type: 'Sculpture', item_category: 'Hand Blown Glass'}
        end

        def self.name_values(args)
          {category_search: args[:f_name]}
        end

        class StandardHandBlownGlass < HandBlownGlass
          def self.assocs
            [:IsHandBlownGlass]
          end

          def self.targets
          end
        end

        class GartnerBlade < HandBlownGlass
          def self.assocs
            [:IsGartnerBlade]
          end

          def self.targets
          end
        end
      end

    end
  end
end


  # def self.edit_list
  #   [['One of a Kind', 'One-of-a-Kind'], ['of One', ' 1/1']]
  # end

  # def self.skip_list
  #   ['of', 'a']
  # end

# class StandardLimitedEdition < LimitedEdition
#   def self.assocs
#     [:IsLimitedEdition, :IsLimitedEditionOrReproduction, :IsLimitedEditionOrUniqueVariation, :IsLimitedEditionOrUniqueVariationOrReproduction]
#   end
#
#   def self.targets
#   end
# end

# class ReproductionPrint < RadioButton
#   def self.art_type(args)
#     cat_hsh[args[:subkind]]
#   end
#
#   def self.art_category(args)
#     cat_hsh['LimitedEdition']
#   end
#
#   def self.category_search(args)
#     args[:subkind]
#   end
#
#   class StandardReproductionPrint < ReproductionPrint
#     def self.targets
#     end
#
#     def self.assocs
#       [:IsReproduction, :IsLimitedEditionOrReproduction, :IsLimitedEditionOrUniqueVariationOrReproduction]
#     end
#   end
# end
