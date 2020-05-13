class MediumType

  # class Painting
  #   module Medium
  #     module SelectFields
  #       def self.build_set
  #         [h={field_name: 'paint-options', options: ['painting', 'oil', 'acrylic', 'mixed media']}]
  #       end
  #     end
  #   end
  #
  #   module Material
  #     module SelectMenu
  #       def self.build_set
  #         [SelectField.build_and_assoc(Material::Canvas.set), SelectField.build_and_assoc(Material::Paper.set),...]
  #       end
  #     end
  #   end
  #
  #
  #   module Medium
  #     def self.set
  #       h={field_name: 'paint-options', options: ['painting', 'oil', 'acrylic', 'mixed media']}
  #     end
  #   end
  #
  #
  # end
  #
  # module FieldSet
  #   def self.build_and_assoc(f)
  #     field_set = FieldSet.where(field_name: f[:field_name]).first_or_create
  #     build_options(field_set, f[:options])
  #   end
  #
  #   def self.build_field_options(field_set, opt_set)
  #   end
  # end
  #
  # module SelectField
  #   def self.build_and_assoc(f)
  #     select_field = SelectField.where(field_name: f[:field_name]).first_or_create
  #     build_options(select_field, f[:options])
  #   end
  #
  #   def build_options(select_field, opt_set)
  #     opt_set.each do |opt_name|
  #       opt = Option.where(field_name: opt_name).first_or_create
  #       assoc_unless_included(select_field, opt)
  #     end
  #     select_field
  #   end
  # end
  #
  # module SelectMenu
  #   def self.build_and_assoc(f)
  #     select_menu = SelectMenu.where(field_name: f[:field_name]).first_or_create
  #     build_options(select_menu, f[:options])
  #   end
  #
  #   def build_options(select_menu, opt_set)
  #     opt_set.each do |opt|
  #       assoc_unless_included(select_field, opt)
  #     end
  #     select_menu
  #   end
  # end
  #
  # # class Material
  # #   module SelectField
  # #     def self.set
  # #       [h={field_name: 'canvas-options', options: ['canvas', 'canvas board', 'textured canvas']}]
  # #     end
  # #   end
  # #
  # #   module SelectField
  # #     def self.set
  # #       [h={field_name: 'paper-options', options: ['paper', 'deckle edge paper', 'rice paper', 'arches paper', 'sommerset paper', 'mother of pearl paper']}]
  # #     end
  # #   end
  # # end
  #
  # module PaintingOnPaper
  # end
  #
  # class LimitedEditionPrint
  # end
  #
  # class UniqueVariationPrint
  # end
  #
  # class StandardPrint
  # end
  #
  # class Drawing
  # end
  #
  # class MixedMediaDrawing
  # end
  #
  # module Sericel
  #   def self.set
  #     ['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline']
  #   end
  # end
  #
  # module BasicPrint
  #   def self.set
  #     ['print', 'fine art print', 'vintage style print']
  #   end
  # end
  #
  # module HandEmbellished
  #   def self.set
  #     ['hand embellished', 'hand painted', 'artist embellished']
  #   end
  # end
  #
  # module HandColored
  #   def self.set
  #     ['hand colored', 'hand watercolored', 'hand colored (pencil)', 'hand tinted']
  #   end
  # end
  #
  # module GoldLeaf
  #   def self.set
  #     ['goldleaf', 'hand laid goldleaf']
  #   end
  # end
  #
  # module SilverLeaf
  #   def self.set
  #     ['silverleaf', 'hand laid silverleaf']
  #   end
  # end
  #
  # module HandPulled
  #   def self.set
  #     ['hand pulled']
  #   end
  # end
end
  ##################
  # module Painting
  #   module Painting
  #   end
  #
  #   module PaintingOnPaper
  #   end
  # end

  # module Drawing
  #   module Drawing
  #   end
  #
  #   module MixedMediaDrawing
  #   end
  # end
  #
  # module Production
  #   module ProductionDrawing
  #   end
  #
  #   module ProductionSericel
  #   end
  #
  #   module ProductionSet
  #   end
  # end

  ##################

  # module Print
  #   module Serigraph
  #   end
  #
  #   module Giclee
  #   end
  #
  #   module MixedMedia
  #   end
  #
  #   module HandPulled
  #   end
  #
  #   module OnPaper
  #     module Lithograph
  #     end
  #
  #     module Etching
  #     end
  #
  #     module Relief
  #     end
  #
  #     module Poster
  #     end
  #   end
  #
  #   module Photograph
  #   end
  #
  #   module Sericel
  #   end
  #
  #   module BasicPrint
  #   end
  #
  # end
