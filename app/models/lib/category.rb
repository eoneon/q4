class Category
  extend Context
  extend FieldKind

  def self.cascade_build(class_a, class_b, class_c, class_d, store)
    f_kind, f_type, subkind, f_name = [class_a, class_b, class_c, class_d].map(&:const)
    tags = tags: build_tags(args: {subkind: subkind, f_name: f_name}, tag_set: tag_set, class_set: [class_d, class_c, class_b])
    f = add_field_and_assoc_targets(f_class: to_class(f_type), f_name: f_name, f_kind: f_kind, tags: class_d.get_tags)
    merge_field(Item.dig_set(k: f_name.to_sym, v: f, dig_keys: [f_kind.to_sym, f_type.to_sym]), store)
  end

  def self.get_tags
    tags = [:art_type, :art_category, :search, :product_name, :field_value].each_with_object({}) do |meth, tags|
      tags.merge!({meth.to_s => public_send(meth)}) if method_exists?(meth)
    end
  end

  def self.tag_set
    [:art_type, :art_category, :search, :product_name, :field_value]
  end

  class RadioButton < Category

    class Original < RadioButton

      def self.art_type(subkind, f_name)
        'Original'
      end

      def self.art_category
        'Original Painting'
      end

      def self.search
        const
      end

      class StandardOriginal < Original
        def self.art_type
          Original.art_type
        end

        def self.art_category
          Original.art_category
        end

        def self.product_name
          art_type
        end

        def self.field_value
          art_type
        end

        def self.search
          art_type
        end
      end

      class OneOfAKind < Original
        # def self.art_type
        #   Original.art_type
        # end
        #
        # def self.art_category
        #   Original.art_category
        # end

        def self.product_name
          'One-of-a-Kind'
        end

        def self.field_value
          product_name
        end

        def self.search
          const
        end
      end

      class OneOfAKindOfOne < Original
        # def self.art_type
        #   Original.art_type
        # end
        #
        # def self.art_category
        #   Original.art_category
        # end

        def self.product_name
          'One-of-a-Kind 1/1'
        end

        def self.field_value
          OneOfAKind.field_value
        end

        def self.search
          const
        end
      end

      class UniqueVariation < Original
        # def self.art_type
        #   Original.art_type
        # end
        #
        # def self.art_category
        #   Original.art_category
        # end

        def self.product_name
          'Unique Variation'
        end

        def self.field_value
          product_name
        end

        def self.search
          const
        end
      end
    end

    class LimitedEdition < RadioButton

      class StandardLimitedEdition < LimitedEdition
        def self.product_name
          'Limited Edition'
        end

        def self.field_value
          product_name
        end

        def self.art_type
          product_name
        end

        def self.art_category
          product_name
        end

        def self.search
          const(-2)
        end
      end
    end

    class ReproductionPrint < RadioButton

      class StandardReproductionPrint < ReproductionPrint
        def self.art_type
          'Print'
        end

        def self.art_category
          'Limited Edition'
        end

        def self.search
          const(-2)
        end
      end
    end

    class Sculpture < RadioButton
      def self.art_type
        'Sculpture/Glass'
      end

      def self.search
        art_category
      end

      class StandardSculpture < Sculpture
        def self.art_type
          Sculpture.art_type
        end

        def self.art_category
          const(-2)
        end

        def self.search
          art_category
        end
      end
    end

    class LimitedEditionSculpture < RadioButton

      class StandardLimitedEditionSculpture < LimitedEditionSculpture
        def self.art_type
          Sculpture.art_type
        end

        def self.art_category
          const(-2)
        end

        def self.search
          art_category
        end

        def self.product_name
          'Limited Edition'
        end

        def self.field_value
          product_name
        end
      end
    end

    class HandBlownGlass < RadioButton

      class StandardHandBlownGlass < HandBlownGlass
        def self.art_type
          Sculpture.art_type
        end

        def self.art_category
          'Hand Blown Glass'
        end

        def self.search
          const(-2)
        end
      end
    end
  end
end
