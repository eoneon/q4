class Sculpture
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.attrs
    {kind: 2, type: 1, subkind: 3, f_name: -1}
  end

  def self.input_group
    [1, %w[size color sculpture_type lid]]
  end

  class SelectField < Sculpture
    def self.target_tags(f_name)
      {tagline: str_edit(str: uncamel(f_name), skip:['and']), body: f_name}
    end

    class SculptureType < SelectField
      def self.name_values(args)
        {product_name: str_edit(str: uncamel(args[:f_name]))}
      end

      class Bowl < SculptureType
        def self.targets
          ['bowl', 'covered bowl']
        end
      end

      class Vase < SculptureType
        def self.targets
          ['vase', 'flat vessel', 'jar']
        end
      end

      class Sculpture < SculptureType
        def self.targets
          ['sculpture']
        end
      end
    end

    class GartnerBlade < SelectField
      class SculptureType < GartnerBlade
        def self.name_values(args)
          {medium_search: args[:f_name], product_name: str_edit(str: uncamel(args[:f_name]))}
        end

        class OpenBowl < SculptureType
          def self.targets
            ['bowl', 'sphere']
          end
        end

        class OpenVase < SculptureType
          def self.targets
            ['cone', 'footed cone', 'traditional urn', 'flat vessel', 'cylinder']
          end
        end

        class CoveredBowl < SculptureType
          def self.targets
            ['bowl', 'covered bowl']
          end
        end

        class CoveredVase < SculptureType
          def self.targets
            ['covered jar', 'closed urn']
          end
        end
      end

      class Lid < GartnerBlade
        def self.targets
          ['marble finial lid', 'avian finial lid', 'leaf and tendril lid', 'bone and tendril lid']
        end
      end

      class Size < GartnerBlade
        def self.targets
          ['large', 'medium', 'small', 'mini']
        end
      end

      class Color < GartnerBlade
        def self.targets
          ['allobaster', 'amethyst', 'batik series', 'black', 'black opal', 'cobalt', 'lapis', 'lime strata', 'opal', 'ruby', 'ruby strata', 'satin finish green', 'tangerine', 'tangerine strata', 'transulscent strata']
        end
      end
    end
  end

  class RadioButton < Sculpture
    class SculptureType < RadioButton
      class PrimitiveBowl < SculptureType
        def self.targets
        end
      end

      class PrimitiveShell < SculptureType
        def self.targets
        end
      end

      class IkebanaFlowerBowl < SculptureType
        def self.targets
        end
      end

      class SaturnOilLamp < SculptureType
        def self.targets
        end
      end

      class ArborSculpture < SculptureType
        def self.targets
        end
      end
    end

    class TextAfterTitle < RadioButton
      class Ikebana < TextAfterTitle
        def self.name_values
          {item_name: "sculpture features a secured Kenzan spiked disc inside - the key to any fine Ikebana style flower arrangement"}
        end

        def self.targets
        end
      end

      class Primitive < TextAfterTitle
        def self.name_values
          {item_name: "sculpture combines sand-etched exteriors with a glossy interior"}
        end

        def self.targets
        end
      end

      class SaturnLamp < TextAfterTitle
        def self.name_values
          {item_name: "features a fiberglass wick to get you started, and when lit, the lamp casts a glowing ring of firelight, evoking the rings of majestic Saturn"}
        end

        def self.targets
        end
      end

      class Arbor < TextAfterTitle
        def self.name_values
          {item_name: "integrates striking colors with graceful curves"}
        end

        def self.targets
        end
      end

      class OpenBowlVase < TextAfterTitle
        def self.name_values
          {item_name: "combines sand-etched exteriors with an elegant lip accent"}
        end

        def self.targets
        end
      end

      class CoveredBowlVase < TextAfterTitle
        def self.name_values
          {item_name: "sculpture combines sand-etched exteriors with an elegant"}
        end

        def self.targets
        end
      end

    end
  end

  class FieldSet < Sculpture
    class SculptureType < FieldSet
      def self.name_values(args)
        {medium_search: args[:f_name], product_name: str_edit(str: uncamel(args[:f_name])), origin: args[:f_name]}
      end

      class PrimitiveBowl < SculptureType
        def self.targets
          [%W[SelectField SculptureType Size], %W[SelectField SculptureType Color], %W[RadioButton SculptureType PrimitiveBowl], %W[RadioButton TextAfterTitle Primitive]]
        end
      end

      class PrimitiveShell < SculptureType
        def self.targets
          [%W[SelectField SculptureType Size], %W[SelectField SculptureType Color], %W[RadioButton SculptureType PrimitiveShell], %W[RadioButton TextAfterTitle Primitive]]
        end
      end

      class IkebanaFlowerBowl < SculptureType
        def self.targets
          [%W[SelectField SculptureType Size], %W[SelectField SculptureType Color], %W[RadioButton SculptureType IkebanaFlowerBowl], %W[RadioButton TextAfterTitle Ikebana]]
        end
      end

      class SaturnOilLamp < SculptureType
        def self.targets
          [%W[SelectField SculptureType Size], %W[SelectField SculptureType Color], %W[RadioButton SculptureType SaturnOilLamp], %W[RadioButton TextAfterTitle SaturnLamp]]
        end
      end

      class ArborSculpture < SculptureType
        def self.targets
          [%W[SelectField SculptureType Size], %W[SelectField SculptureType Color], %W[RadioButton SculptureType ArborSculpture], %W[RadioButton TextAfterTitle Arbor]]
        end
      end

      class OpenBowl < SculptureType
        def self.targets
          [%W[SelectField SculptureType Size], %W[SelectField SculptureType Color], %W[SelectField SculptureType OpenBowl], %W[RadioButton TextAfterTitle OpenBowlVase]]
        end
      end

      class OpenVase < SculptureType
        def self.targets
          [%W[SelectField SculptureType Size], %W[SelectField SculptureType Color], %W[SelectField SculptureType OpenVase], %W[RadioButton TextAfterTitle OpenBowlVase]]
        end
      end

      class CoveredBowl < SculptureType
        def self.targets
          [%W[SelectField SculptureType Size], %W[SelectField SculptureType Color], %W[SelectField SculptureType CoveredBowl], %W[SelectField SculptureType Lid], %W[RadioButton TextAfterTitle CoveredBowlVase]]
        end
      end

      class CoveredVase < SculptureType
        def self.targets
          [%W[SelectField SculptureType Size], %W[SelectField SculptureType Color], %W[SelectField SculptureType CoveredVase], %W[SelectField SculptureType Lid], %W[RadioButton TextAfterTitle CoveredBowlVase]]
        end
      end
    end
  end
end
