class GartnerBlade
  include ClassContext
  include FieldSeed
  include Hashable

  def self.builder(store)
    field_group(:targets, store)
  end

  def self.attrs
    {kind: 2, type: 1, f_name: -1}
  end

  class SelectField < GartnerBlade

    class SculptureType < SelectField
      # def self.set
      #   [:ForGartnerBlade]
      # end

      class OpenBowl < SculptureType
        def self.targets
          ['bowl', 'sphere']
        end
      end

      class OpenVase < SculptureType
        def self.targets
          ['cone', 'footed cone', 'traditional urn', 'closed urn', 'flat vessel', 'cylinder']
        end
      end

      class ForCovered < SculptureType
        # def self.set
        #   [:ForCovered]
        # end

        class CoveredBowl < ForCovered
          def self.targets
            ['bowl', 'covered bowl']
          end
        end

        class CoveredVase < ForCovered
          def self.targets
            ['covered jar']
          end
        end
      end

      class ForPrimitive < SculptureType
        def self.set
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

      class Ikebana < SculptureType
        def self.targets
          ['ikebana flower bowl']
        end
      end

      class SaturnLamp < SculptureType
        def self.targets
          ['Saturn oil lamp']
        end
      end
    end

    class Lid < SelectField
      class GartnerBladeLid < Lid
        def self.targets
          ['bowl', 'sphere']
        end
      end
    end

    class Size < SelectField
      class GartnerBladeSize < Size
        def self.targets
          ['large', 'medium', 'small', 'mini']
        end
      end
    end

    class Color < SelectField
      class GartnerBladeColor < Color
        def self.targets
          ['allobaster', 'amethyst', 'batik series', 'black', 'black opal', 'cobalt', 'lapis', 'lime strata', 'opal', 'ruby', 'ruby strata', 'satin finish green', 'tangerine', 'tangerine strata', 'transulscent strata']
        end
      end
    end

  end
end
