class Category
  include ClassContext
  include FieldSeed
  include Hashable

  def self.builder(store)
    args = build_attrs(:attrs)
    add_field_group(to_class(args[:type]), self, args[:type], args[:kind], args[:f_name], store, build_tags(args, :art_type, :art_category, :search, :product_name, :field_value))
  end

  def self.attrs
    {kind: 0, type: 1, subkind: 2, f_name: -1}
  end

  def self.cat_hsh
    {'Original'=> 'Original Painting', 'StandardOriginal'=> 'Original', 'OneOfAKind'=> 'One-of-a-Kind', 'OneOfAKindOfOne'=> 'One-of-a-Kind 1/1', 'UniqueVariation'=> 'Unique Variation', 'ReproductionPrint'=> 'Print', 'LimitedEdition'=> 'Limited Edition', 'Sculpture'=> 'Sculpture/Glass'}
  end

  class RadioButton < Category

    def self.assoc_group
      kind, type = [:kind,:type].map{|k| build_attrs(:attrs)[k].to_sym}
      merge_enum(:targets, :group, kind, type)
    end

    class Original < RadioButton
      def self.art_type(args)
        cat_hsh[args[:subkind]]
      end

      def self.art_category(args)
        cat_hsh[args[:subkind]]
      end

      def self.search(args)
        args[:f_name]
      end

      def self.product_name(args)
        cat_hsh[args[:f_name]]
      end

      def self.field_value(args)
        cat_hsh[args[:f_name]]
      end

      # def self.group
      #   [:IsOriginal, :IsOriginalOrOneOfAKind, :IsOneOfAKindOfOne]
      # end

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

        def self.search(args)
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

      def self.search(args)
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

      def self.search(args)
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

      def self.art_category(args)
        args[:subkind]
      end

      def self.search(args)
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

        def self.search(args)
          args[:f_name]
        end

        def self.group
          [:IsLimitedEditionSculpture, :IsLimitedEditionSculptureOrSculpture]
        end

        def self.targets
        end
      end

      class HandBlownGlass < Sculpture
        def self.art_category(args)
          cat_hsh[args[:f_name]]
        end

        def self.search(args)
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


  # def self.cascade_build(store)
  #   f_kind, f_type, subkind, f_name = f_attrs(0, 1, 2, 3)
  #   tags = build_tags(args: {subkind: subkind, f_name: f_name}, tag_set: tag_set, class_set: class_tree(0,3))
  #   add_field_group(to_class(f_type), self, f_type, f_kind, f_name, store, tags)
  # end

  # def self.tag_set
  #   [:art_type, :art_category, :search, :product_name, :field_value]
  # end
