class GartnerBlade
  extend Context
  extend FieldKind

  def self.cascade_build(store)
    f_type, f_kind, f_name = f_attrs(1, 2, 3)
    add_field_group(to_class(f_type), self, f_type, f_kind, f_name, store)
  end

  class SelectField < GartnerBlade

    class SculptureType < SelectField
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

      class CoveredBowl < SculptureType
        def self.targets
          ['bowl', 'covered bowl']
        end
      end

      class CoveredVase < SculptureType
        def self.targets
          ['covered jar']
        end
      end

      class PrimitiveBowl < SculptureType
        def self.targets
          ['primitive bowl']
        end
      end

      class PrimitiveShell < SculptureType
        def self.targets
          ['primitive shell']
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
