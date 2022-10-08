class Sculpture
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.attrs
    {kind: 2, type: 1, subkind: 3, field_name: -1}
  end

  def self.input_group
    [1, %w[sculpture_type sculpture_part text_after_title]]
  end

  class SelectField < Sculpture
    def self.target_tags(f_name)
      name = str_edit(str: uncamel(f_name))
      {tagline: name, body: name.downcase}
    end

    class SculptureType < SelectField
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

      class Plate < SculptureType
        def self.targets
          ['plate', 'commemorative plate', 'collectable plate', 'platter']
        end
      end

      class Sculpture < SculptureType
        def self.targets
          ['sculpture']
        end
      end
    end

    class Medium < SelectField
      def self.admin_attrs(args)
        {item_category: str_edit(str: uncamel(args[:field_name]), swap: ['Sculpture', ''])}
      end

      class AcrylicSculpture < Medium
        def self.targets
          ['acrylic', 'lucite']
        end
      end

      class GlassSculpture < Medium
        def self.targets
          ['glass']
        end
      end

      class PewterSculpture < Medium
        def self.targets
          ['pewter', 'mixed media pewter']
        end
      end

      class PorcelainSculpture < Medium
        def self.targets
          ['porcelain']
        end
      end

      class ResinSculpture < Medium
        def self.targets
          ['resin', 'mixed media resin']
        end
      end

      class MixedMediaSculpture < Medium
        def self.targets
          ['mixed media', 'lucite and pewter']
        end
      end
    end

    class GartnerBlade < SelectField
      def self.attrs
        {kind: 3, subkind: 2, field_name: -1}
      end

      def self.target_tags(f_name)
        name = str_edit(str: f_name)
        {tagline: name, body: name}
      end

      class SculptureType < GartnerBlade
        class OpenBowl < SculptureType
          def self.targets
            ['bowl', 'open bowl', 'sphere']
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

        class IkebanaFlowerBowl < SculptureType
          def self.targets
            ['ikebana flower bowl']
          end
        end

        class SaturnOilLamp < SculptureType
          def self.targets
            ['saturn oil lamp']
          end
        end

        class ArborSculpture < SculptureType
          def self.targets
            ['arbor sculpture']
          end
        end
      end

      class SculpturePart < GartnerBlade
        class Lid < SculpturePart
          def self.target_tags(f_name)
            name = str_edit(str: f_name, skip:['and'])
            {tagline: "with #{name}", body: "with #{name}"}
          end

          def self.targets
            ['marble finial lid', 'avian finial lid', 'leaf and tendril lid', 'bone and tendril lid']
          end
        end

        class Size < SculpturePart
          def self.targets
            ['large', 'medium', 'small', 'mini']
          end
        end

        class Color < SculpturePart
          def self.targets
            ['allobaster', 'amethyst', 'batik series', 'black', 'black opal', 'cobalt', 'lapis', 'lime strata', 'opal', 'ruby', 'ruby strata', 'satin finish green', 'tangerine', 'tangerine strata', 'transulscent strata']
          end
        end
      end
    end
  end

  class SelectMenu < Sculpture
    class SculptureType < SelectMenu
      class StandardSculpture < SculptureType
        def self.targets
          build_target_group(%W[Bowl Vase Plate Sculpture], 'FieldSet', 'SculptureType')
        end
      end
    end
  end

  class RadioButton < Sculpture
    class TextAfterTitle < RadioButton
      class Ikebana < TextAfterTitle
        def self.name_values
          {body: "features a secured Kenzan spiked disc inside - the key to any fine Ikebana style flower arrangement."}
        end

        def self.targets
        end
      end

      class Primitive < TextAfterTitle
        def self.name_values
          {body: "combines sand-etched exteriors with a glossy interior."}
        end

        def self.targets
        end
      end

      class SaturnLamp < TextAfterTitle
        def self.name_values
          {body: "features a fiberglass wick to get you started, and when lit, the lamp casts a glowing ring of firelight, evoking the rings of majestic Saturn."}
        end

        def self.targets
        end
      end

      class Arbor < TextAfterTitle
        def self.name_values
          {body: "integrates striking colors with graceful curves."}
        end

        def self.targets
        end
      end

      class OpenBowlVase < TextAfterTitle
        def self.name_values
          {body: "combines sand-etched exteriors with an elegant lip accent."}
        end

        def self.targets
        end
      end

      class CoveredBowlVase < TextAfterTitle
        def self.name_values
          {body: "combines sand-etched exteriors with an elegant."}
        end

        def self.targets
        end
      end

    end
  end

  class FieldSet < Sculpture
    class SculptureType < FieldSet
      class SculptureMedium < SculptureType
        def self.name_values(args)
          {medium_search: args[:field_name], product_name: str_edit(str: uncamel(args[:field_name])), origin: args[:field_name]}
        end

        class PrimitiveBowl < SculptureMedium
          def self.targets
            [%W[SelectField SculpturePart Size], %W[SelectField SculpturePart Color], %W[SelectField SculptureType PrimitiveBowl], %W[RadioButton TextAfterTitle Primitive], %W[FieldSet Dimension DiameterHeightWeight]]
          end
        end

        class PrimitiveShell < SculptureMedium
          def self.targets
            [%W[SelectField SculpturePart Size], %W[SelectField SculpturePart Color], %W[SelectField SculptureType PrimitiveShell], %W[RadioButton TextAfterTitle Primitive], %W[FieldSet Dimension WidthHeightDepthWeight]]
          end
        end

        class IkebanaFlowerBowl < SculptureMedium
          def self.targets
            [%W[SelectField SculpturePart Size], %W[SelectField SculpturePart Color], %W[SelectField SculptureType IkebanaFlowerBowl], %W[RadioButton TextAfterTitle Ikebana], %W[FieldSet Dimension DiameterHeightWeight]]
          end
        end

        class SaturnOilLamp < SculptureMedium
          def self.targets
            [%W[SelectField SculpturePart Size], %W[SelectField SculpturePart Color], %W[SelectField SculptureType SaturnOilLamp], %W[RadioButton TextAfterTitle SaturnLamp], %W[FieldSet Dimension DiameterHeightWeight]]
          end
        end

        class ArborSculpture < SculptureMedium
          def self.targets
            [%W[SelectField SculpturePart Size], %W[SelectField SculpturePart Color], %W[SelectField SculptureType ArborSculpture], %W[RadioButton TextAfterTitle Arbor], %W[FieldSet Dimension WidthHeightDepthWeight]]
          end
        end

        class OpenBowl < SculptureMedium
          def self.targets
            [%W[SelectField SculpturePart Size], %W[SelectField SculpturePart Color], %W[SelectField SculptureType OpenBowl], %W[RadioButton TextAfterTitle OpenBowlVase], %W[FieldSet Dimension DiameterHeightWeight]]
          end
        end

        class OpenVase < SculptureMedium
          def self.targets
            [%W[SelectField SculpturePart Size], %W[SelectField SculpturePart Color], %W[SelectField SculptureType OpenVase], %W[RadioButton TextAfterTitle OpenBowlVase], %W[FieldSet Dimension DiameterHeightWeight]]
          end
        end

        class CoveredBowl < SculptureMedium
          def self.targets
            [%W[SelectField SculpturePart Size], %W[SelectField SculpturePart Color], %W[SelectField SculptureType CoveredBowl], %W[SelectField SculpturePart Lid], %W[RadioButton TextAfterTitle CoveredBowlVase], %W[FieldSet Dimension WidthHeightDepthWeight]]
          end
        end

        class CoveredVase < SculptureMedium
          def self.targets
            [%W[SelectField SculpturePart Size], %W[SelectField SculpturePart Color], %W[SelectField SculptureType CoveredVase], %W[SelectField SculpturePart Lid], %W[RadioButton TextAfterTitle CoveredBowlVase], %W[FieldSet Dimension WidthHeightDepthWeight]]
          end
        end

        # StandardSculpture ######################################################
        class AcrylicSculpture < SculptureMedium
          def self.targets
            [%W[SelectField Medium AcrylicSculpture], %W[SelectMenu SculptureType StandardSculpture]]
          end
        end

        class GlassSculpture < SculptureMedium
          def self.targets
            [%W[SelectField Medium GlassSculpture], %W[SelectMenu SculptureType StandardSculpture]]
          end
        end

        class PewterSculpture < SculptureMedium
          def self.targets
            [%W[SelectField Medium PewterSculpture], %W[SelectMenu SculptureType StandardSculpture]]
          end
        end

        class PorcelainSculpture < SculptureMedium
          def self.targets
            [%W[SelectField Medium PorcelainSculpture], %W[SelectMenu SculptureType StandardSculpture]]
          end
        end

        class ResinSculpture < SculptureMedium
          def self.targets
            [%W[SelectField Medium ResinSculpture], %W[SelectMenu SculptureType StandardSculpture]]
          end
        end

        class MixedMediaSculpture < SculptureMedium
          def self.targets
            [%W[SelectField Medium MixedMediaSculpture], %W[SelectMenu SculptureType StandardSculpture]]
          end
        end

        # HandMadeSculpture ######################################################
        class HandMadeCeramic < SculptureType
          def self.targets
            [%W[RadioButton Category HandMadeCeramic], %W[SelectMenu SculptureType StandardSculpture]]
          end
        end

        class HandBlownGlass < SculptureType
          def self.targets
            [%W[RadioButton Category StandardHandBlownGlass], %W[SelectMenu SculptureType StandardSculpture]]
          end
        end
      end

      class SculptureDimension < SculptureType
        class Bowl < SculptureDimension
          def self.targets
            [%W[SelectField SculptureType Bowl], %W[FieldSet Material WidthHeightDepthType]]
          end
        end

        class Vase < SculptureDimension
          def self.targets
            [%W[SelectField SculptureType Vase], %W[FieldSet Material WidthHeightDepthType]]
          end
        end

        class Plate < SculptureDimension
          def self.targets
            [%W[SelectField SculptureType Plate], %W[FieldSet Material DiameterType]]
          end
        end

        class Sculpture < SculptureDimension
          def self.targets
            [%W[SelectField SculptureType Sculpture], %W[FieldSet Material WidthHeightDepthType]]
          end
        end
      end
    end
  end
end
