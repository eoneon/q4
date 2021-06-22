class GartnerBlade
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable

  def self.attrs
    {kind: 2, type: 1, f_name: -1}
  end

  class SelectField < GartnerBlade

    class SculptureType < SelectField
      def self.name_values(args)
        {medium_search: args[:f_name], product_name: class_to_cap(args[:f_name])}
      end

      def self.origin
        [:ForGartnerBlade]
      end

      class OpenBowlVase < SculptureType
        def self.origin
          [:OpenBowlVase]
        end

        class OpenBowl < OpenBowlVase
          def self.targets
            ['bowl', 'sphere']
          end
        end

        class OpenVase < OpenBowlVase
          def self.targets
            ['cone', 'footed cone', 'traditional urn', 'flat vessel', 'cylinder']
          end
        end
      end

      class ForCovered < SculptureType
        def self.origin
          [:ForCovered]
        end

        class CoveredBowl < ForCovered
          def self.targets
            ['bowl', 'covered bowl']
          end
        end

        class CoveredVase < ForCovered
          def self.targets
            ['covered jar', 'closed urn']
          end
        end
      end

      class ForPrimitive < SculptureType
        def self.origin
          [:ForPrimitive]
        end

        class PrimitiveBowl < ForPrimitive
          def self.targets
            ['primitive bowl']
          end
        end

        class PrimitiveShell < ForPrimitive
          def self.targets
            ['primitive shell']
          end
        end
      end

      class IkebanaFlowerBowl < SculptureType
        def self.origin
          [:ForIkebana]
        end

        def self.targets
          ['ikebana flower bowl']
        end
      end

      class SaturnOilLamp < SculptureType
        def self.origin
          [:ForSaturn]
        end

        def self.targets
          ['saturn oil lamp']
        end
      end

      class ArborSculpture < SculptureType
        def self.origin
          [:ForArbor]
        end

        def self.targets
          ['arbor sculpture']
        end
      end
    end

    class GartnerBladeElement < SelectField
      class GartnerBladeLid < GartnerBladeElement
        def self.assocs
          [:ForCovered]
        end

        def self.targets
          ['marble finial lid', 'avian finial lid', 'leaf and tendril lid', 'bone and tendril lid']
        end
      end

      class GartnerBladeSize < GartnerBladeElement
        def self.assocs
          [:ForGartnerBlade]
        end

        def self.targets
          ['large', 'medium', 'small', 'mini']
        end
      end

      class GartnerBladeColor < GartnerBladeElement
        def self.assocs
          [:ForGartnerBlade]
        end

        def self.targets
          ['allobaster', 'amethyst', 'batik series', 'black', 'black opal', 'cobalt', 'lapis', 'lime strata', 'opal', 'ruby', 'ruby strata', 'satin finish green', 'tangerine', 'tangerine strata', 'transulscent strata']
        end
      end

    end

  end
end
