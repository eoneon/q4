class ArtistFlatArt
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  class Medium < ArtistFlatArt
    def self.attrs
      {kind: 1, type: 2, subkind: 3, f_name: -1}
    end

    def self.name_values(args)
      {medium_search: args[:f_name], product_name: class_to_cap(args[:f_name])}
    end

    def self.admin_attrs(args)
      {medium: name_from_class(args[:f_name], [], [['PeterMax', ''], ['Kaufman', ''], ['Everhart','']])}
    end

    class SelectField < Medium
      def self.origin
        [:IsDisclaimer]
      end

      class PeterMax < SelectField
        def self.origin
          [:PeterMaxAuthentication, :OnPaper]
        end

        class LimitedEdition < PeterMax
          def self.origin
            [:IsLimitedEdition]
          end

          class PeterMaxLithograph < LimitedEdition
            def self.targets
              ['lithograph']
            end
          end

          class PeterMaxEtching < LimitedEdition
            def self.targets
              ['etching']
            end
          end
        end

        class OneOfAKind < PeterMax
          def self.origin
            [:IsOneOfAKind]
          end

          class PeterMaxMixedMedia < OneOfAKind
            def self.targets
              ['acrylic mixed media']
            end
          end
        end
      end

      class Kaufman < SelectField
        def self.origin
          [:StandardAuthentication]
        end

        class KaufmanMixedMedia < Kaufman
          def self.origin
            [:IsLimitedEditionOrUniqueVariation, :IsOneOfAKindOrOneOfAKindOfOne, :StandardSubmedia]
          end

          def self.targets
            ['mixed media']
          end
        end

        class KaufmanSilkscreen < Kaufman
          def self.origin
            [:IsLimitedEditionOrReproduction, :IsOneOfAKindOfOne]
          end

          def self.targets
            ['hand pulled silkscreen']
          end
        end
      end

      class Everhart < SelectField
        class EverhartLithograph < Everhart
          def self.origin
            [:IsLimitedEdition, :IsEverhart]
          end

          def self.targets
            ['original hand pulled lithograph']
          end
        end
      end
    end
  end
end
