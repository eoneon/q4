class SculptureArt
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.attrs
    {kind: 2, type: 1, subkind: 3, f_name: -1}
  end

  class SelectField < SculptureArt
    class Medium < SelectField
      def self.admin_attrs(args)
        {item_type: name_from_class(args[:f_name], [], [['Sculpture', ''], ['Hand Made', '']])}
      end

      def self.name_values(args)
        {medium_search: args[:f_name], product_name: class_to_cap(args[:f_name].sub('Standard', ''))}
      end

      def self.origin
        [:ForSculptureType, :StandardAuthentication, :IsDisclaimer]
      end

      class StandardSculpture < Medium
        def self.origin
          [:IsLimitedEditionSculptureOrSculpture]
        end

        class AcrylicSculpture < StandardSculpture
          def self.targets
            ['acrylic', 'lucite']
          end
        end

        class GlassSculpture < StandardSculpture
          def self.targets
            ['glass']
          end
        end

        class PewterSculpture < StandardSculpture
          def self.targets
            ['pewter', 'mixed media pewter']
          end
        end

        class PorcelainSculpture < StandardSculpture
          def self.targets
            ['porcelain']
          end
        end

        class ResinSculpture < StandardSculpture
          def self.targets
            ['resin', 'mixed media resin']
          end
        end

        class MixedMediaSculpture < StandardSculpture
          def self.targets
            ['mixed media', 'lucite and pewter']
          end
        end
      end

      class HandMadeSculpture < Medium
        def self.origin
          [:ForSculptureType]
        end

        class HandMadeCeramic < HandMadeSculpture
          def self.origin
            [:IsSculpture]
          end

          def self.targets
            ['hand made ceramic']
          end
        end

        class HandBlownGlass < HandMadeSculpture
          def self.origin
            [:IsHandBlownGlass]
          end

          def self.targets
            ['hand blown glass']
          end
        end
      end
    end

    class SculptureType < SelectField
      def self.assocs
        [:ForSculptureType]
      end

      class Flatware < SculptureType
        def self.name_values(args)
          {product_name: class_to_cap(args[:f_name])}
        end

        class Bowl < Flatware
          def self.targets
            ['bowl', 'covered bowl']
          end
        end

        class Vase < Flatware
          def self.targets
            ['vase', 'flat vessel', 'jar']
          end
        end
      end

      class Sculpture < SculptureType
        def self.targets
          ['sculpture']
        end
      end
    end

  end
end
