class Medium
  extend Context
  extend FieldKind

  class SelectField < Medium

    def self.cascade_build(class_a, class_b, class_c, class_d, store)
      f_kind, f_type, subkind, f_name = [class_a, class_b, class_c, class_d].map(&:const)
      f = add_field_and_assoc_targets(f_class: to_class(f_type), f_name: f_name, f_kind: f_kind, targets: class_d.targets, tags: {'subkind'=> subkind})
      merge_field(Item.dig_set(k: f_name.to_sym, v: f, dig_keys: [f_kind.to_sym, f_type.to_sym]), store)
    end

    def self.targets
      ['Medium::OptionTarget', const.to_s].join('::').constantize.targets.map{|f_name| add_field(Option, f_name, 'Medium')}
    end

    class Painting < SelectField
      class StandardPainting < Painting
      end

      class PaintingOnPaper < Painting
      end
    end

    class Drawing < SelectField
      class StandardPainting < Drawing
      end

      class MixedMediaDrawing < Drawing
      end
    end

    class Silkscreen < SelectField
      class StandardSilkscreen < Silkscreen
      end

      class HandPulledSilkscreen < Silkscreen
      end
    end

    class Lithograph < SelectField
      class StandardLithograph < Lithograph
      end

      class HandPulledLithograph < Lithograph
      end
    end

    class Giclee < SelectField
      class StandardGiclee < Giclee
      end
    end

    class Etching < SelectField
      class StandardEtching < Etching
      end
    end

    class Relief < SelectField
      class StandardRelief < Relief
      end
    end

    class MixedMedia < SelectField
      class StandardMixedMedia < MixedMedia
      end

      class AcrylicMixedMedia < MixedMedia
      end

      class Monotype < MixedMedia
      end

      class Seriolithograph < MixedMedia
      end
    end

    class PrintMedia < SelectField
      class StandardPrint < PrintMedia
      end
    end

    class Poster < SelectField
      class StandardPoster < Poster
      end
    end

    class Photograph < SelectField
      class StandardPhotograph < Photograph
      end

      class SingleExposurePhotograph < Photograph
      end

      class SportsPhotograph < Photograph
      end

      class ConcertPhotograph < Photograph
      end

      class PressPhotograph < Photograph
      end
    end

    class Sericel < SelectField
      class StandardSericel < Sericel
      end
    end

    class ProductionArt < SelectField
      class ProductionCel < ProductionArt
      end

      class ProductionDrawing < ProductionArt
      end
    end

    class Sculpture < SelectField
      class StandardSculpture < Sculpture
      end

      class HandBlownGlass < Sculpture
      end

      class GartnerBladeGlass < Sculpture
      end
    end
  end

  module OptionTarget
    module StandardPainting
      def self.targets
        ['oil painting', 'acrylic painting', 'mixed media painting', 'painting']
      end
    end

    module PaintingOnPaper
      def self.targets
        ['watercolor painting', 'pastel painting', 'guache painting', 'sumi ink painting', 'oil painting', 'acrylic painting', 'mixed media painting', 'painting']
      end
    end

    module StandardDrawing
      def self.targets
        ['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing']
      end
    end

    module MixedMediaDrawing
      def self.targets
        StandardDrawing.targets
      end
    end

    module StandardSilkscreen
      def self.targets
        ['serigraph', 'original serigraph', 'silkscreen']
      end
    end

    module HandPulledSilkscreen
      def self.targets
        ['hand pulled serigraph', 'hand pulled original serigraph', 'hand pulled silkscreen']
      end
    end

    module StandardLithograph
      def self.targets
        ['lithograph', 'offset lithograph', 'original lithograph', 'hand pulled lithograph', 'hand pulled original lithograph']
      end
    end

    module HandPulledLithograph
      def self.targets
        ['hand pulled lithograph', 'hand pulled original lithograph']
      end
    end

    module StandardGiclee
      def self.targets
        ['giclee', 'textured giclee']
      end
    end

    module StandardEtching
      def self.targets
        ['etching', 'etching (black)', 'etching (sepia)', 'hand pulled etching', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint']
      end
    end

    module StandardRelief
      def self.targets
        ['relief', 'mixed media relief', 'linocut', 'woodblock print', 'block print']
      end
    end

    module StandardMixedMedia
      def self.targets
        ['mixed media']
      end
    end

    module AcrylicMixedMedia
      def self.targets
        ['acrylic mixed media']
      end
    end

    module Monotype
      def self.targets
        ['monotype', 'monoprint']
      end
    end

    module Seriolithograph
      def self.targets
        ['seriolithograph']
      end
    end

    module StandardPrint
      def self.targets
        ['print', 'fine art print', 'vintage style print']
      end
    end

    module StandardPoster
      def self.targets
        ['poster', 'vintage poster', 'concert poster']
      end
    end

    module StandardPhotograph
      def self.targets
        ['photograph']
      end
    end

    module SingleExposurePhotograph
      def self.targets
        ['single exposure photograph']
      end
    end

    module SportsPhotograph
      def self.targets
        ['photograph', 'archival sports photograph']
      end
    end

    module ConcertPhotograph
      def self.targets
        ['photograph', 'concert photograph', 'archival concert photograph']
      end
    end

    module PressPhotograph
      def self.targets
        ['vintage press photograph']
      end
    end

    module StandardSericel
      def self.targets
        ['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline']
      end
    end

    module ProductionCel
      def self.targets
        ['production cel', 'production cel and matching drawing', 'production cel and two matching drawings', 'production cel and three matching drawings']
      end
    end

    module ProductionDrawing
      def self.targets
        ['production drawing', 'production drawing set']
      end
    end

    module StandardSculpture
      def self.targets
        ['glass', 'ceramic', 'bronze', 'acrylic', 'lucite', 'resin', 'pewter', 'mixed media']
      end
    end

    module HandBlownGlass
      def self.targets
        ['hand blown glass']
      end
    end

    module GartnerBladeGlass
      def self.targets
        HandBlownGlass.targets
      end
    end

  end
end

# class Target < Medium
#   class StandardPainting < Target
#     def self.targets
#       ['oil painting', 'acrylic painting', 'mixed media painting', 'painting']
#     end
#   end
#
#   class PaintingOnPaper < Target
#     def self.targets
#       ['watercolor painting', 'pastel painting', 'guache painting', 'sumi ink painting', 'oil painting', 'acrylic painting', 'mixed media painting', 'painting']
#     end
#   end
#
#   class StandardDrawing < Target
#     def self.targets
#       ['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing']
#     end
#   end
#
#   class MixedMediaDrawing < Target
#     def self.targets
#       StandardDrawing.targets
#     end
#   end
#
#   class StandardSilkscreen < Target
#     def self.targets
#       ['serigraph', 'original serigraph', 'silkscreen']
#     end
#   end
#
#   class HandPulledSilkscreen < Target
#     def self.targets
#       ['hand pulled serigraph', 'hand pulled original serigraph', 'hand pulled silkscreen']
#     end
#   end
#
#   class StandardLithograph < Target
#     def self.targets
#       ['lithograph', 'offset lithograph', 'original lithograph', 'hand pulled lithograph', 'hand pulled original lithograph']
#     end
#   end
#
#   class HandPulledLithograph < Target
#     def self.targets
#       ['hand pulled lithograph', 'hand pulled original lithograph']
#     end
#   end
#
#   class StandardGiclee < Target
#     def self.targets
#       ['giclee', 'textured giclee']
#     end
#   end
#
#   class StandardEtching < Target
#     def self.targets
#       ['etching', 'etching (black)', 'etching (sepia)', 'hand pulled etching', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint']
#     end
#   end
#
#   class StandardRelief < Target
#     def self.targets
#       ['relief', 'mixed media relief', 'linocut', 'woodblock print', 'block print']
#     end
#   end
#
#   class StandardMixedMedia < Target
#     def self.targets
#       ['mixed media']
#     end
#   end
#
#   class AcrylicMixedMedia < Target
#     def self.targets
#       ['acrylic mixed media']
#     end
#   end
#
#   class Monotype < Target
#     def self.targets
#       ['monotype', 'monoprint']
#     end
#   end
#
#   class Seriolithograph < Target
#     def self.targets
#       ['seriolithograph']
#     end
#   end
#
#   class StandardPrint < Target
#     def self.targets
#       ['print', 'fine art print', 'vintage style print']
#     end
#   end
#
#   class StandardPoster < Target
#     def self.targets
#       ['poster', 'vintage poster', 'concert poster']
#     end
#   end
#
#   class StandardPhotograph < Target
#     def self.targets
#       ['photograph']
#     end
#   end
#
#   class SingleExposurePhotograph < Target
#     def self.targets
#       ['single exposure photograph']
#     end
#   end
#
#   class SportsPhotograph < Target
#     def self.targets
#       ['photograph', 'archival sports photograph']
#     end
#   end
#
#   class ConcertPhotograph < Target
#     def self.targets
#       ['photograph', 'concert photograph', 'archival concert photograph']
#     end
#   end
#
#   class PressPhotograph < Target
#     def self.targets
#       ['vintage press photograph']
#     end
#   end
#
#   class StandardSericel < Target
#     def self.targets
#       ['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline']
#     end
#   end
#
#   class ProductionCel < Target
#     def self.targets
#       ['production cel', 'production cel and matching drawing', 'production cel and two matching drawings', 'production cel and three matching drawings']
#     end
#   end
#
#   class ProductionDrawing < Target
#     def self.targets
#       ['production drawing', 'production drawing set']
#     end
#   end
#
#   class StandardSculpture < Target
#     def self.targets
#       ['glass', 'ceramic', 'bronze', 'acrylic', 'lucite', 'resin', 'pewter', 'mixed media']
#     end
#   end
#
#   class HandBlownGlass < Target
#     def self.targets
#       ['hand blown glass']
#     end
#   end
#
#   class GartnerBladeGlass < Target
#     def self.targets
#       HandBlownGlass.targets
#     end
#   end
#
# end
