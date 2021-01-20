module PRD
  extend Build
  # PRD::Painting.opts[:StandardPainting]

  # [medium_type medium_type medium material]
  # def seed_products(store: seed_fields, products=[])
  #   constants.each do |type| #Painting
  #     modulize(self, type).opts.each do |subtype, field_group| # StandardPainting, field_group
  #       p_hsh = build_key_group(field_group[:key_group], store)
  #       build_fgo(p_hsh, field_group.dig(:FGO), store, products)
  #       build_fso(field_group.dig(:FGS), store, products)
  #     end
  #   end
  #   products
  # end
  #
  # def build_key_group(key_group, store, p={})
  #   key_group.each do |keys| #[:RadioButton, :Category, :Original]
  #     p.merge({keys[1] => store.dig(*keys)}) # {:Category => <RadioButton>}
  #   end
  #   p
  # end
  #
  # def build_fgo(p_hsh, key_group, store, products)
  #   return products << p_hsh if !key_group
  #   key_group.each do |keys|
  #     store.dig(*keys).each do |f|
  #       p = p_hsh.dup
  #       products << p.merge!({keys[1] => f})
  #     end
  #   end
  #   products
  # end
  #
  # def build_fgs(key_group, store, products)
  #   return products if !key_group
  #   key_group.each do |keys|
  #     store.dig(*keys).each do |f|
  #       products.map{|p| p.merge!({keys[1] => f})}
  #     end
  #   end
  #   products
  # end

  ##############################################################################

  module Painting
    def self.opts
      {
        StandardPainting: {
          key_group: [[:RadioButton, :Category, :Original], [:SelectField, :Medium, :StandardPainting]],
          FGO: [[:FGO, :Material, :Standard]],
          FGS: [[:FGS, :Authentication, :Standard]]
        },

        PaintingOnPaper: {
          key_group: [[:RadioButton, :Category, :Original], [:SelectField, :Medium, :PaintingOnPaper]],
          FGO: [[:FGO, :Material, :Paper]],
          FGS: [[:FGS, :Authentication, :Standard]]
        }
      }
    end
  end
  #
  # module Drawing
  #   def self.opts
  #     {
  #       StandardDrawing: [
  #         RBTN::Category.opts[:Original],
  #         SFO::Medium.opts[:StandardDrawing],
  #         FSO::Material.opts[:Paper],
  #         FG::Authentication.opts[:Authentication]
  #       ],
  #
  #       MixedMediaDrawing: [
  #         RBTN::Category.opts[:Original],
  #         SFO::Medium.opts[:PaintingOnPaper],
  #         FSO::Material.opts[:Paper],
  #         FG::Submedia.opts[:DrawingSubmedia],
  #         FG::Authentication.opts[:Authentication]
  #       ]
  #     }
  #   end
  # end
  #
  # module OneOfAKindMixedMedia
  #   def self.opts
  #     {
  #       MixedMediaOnPaper: [
  #         RBTN::Category.opts[:OneOfAKind],
  #         FGO::Medium.opts[:OneOfAKindMixedMediaOnPaper],
  #         FSO::Material.opts[:Paper],
  #         FG::Submedia.opts[:SubmediaOnPaper],
  #         FG::Authentication.opts[:Authentication]
  #       ],
  #
  #       MixedMediaOnCanvas: [
  #         RBTN::Category.opts[:OneOfAKind],
  #         SFO::Medium.opts[:AcrylicMixedMedia],
  #         FSO::Material.opts[:Canvas],
  #         FG::Submedia.opts[:StandardSubmedia],
  #         FG::Authentication.opts[:Authentication]
  #       ]
  #     }
  #   end
  # end
  #
  #
  # module MixedMedia
  #   def self.opts
  #     {
  #       MixedMedia: [
  #         #RBTN::Category.opts[:OneOfAKind],       #add LimitedEdition, SingleEdition
  #         SFO::Medium.opts[:BasicMixedMedia],
  #         FGO::Material.opts[:StandardMaterial],
  #         FG::Submedia.opts[:StandardSubmedia],
  #         FG::Authentication.opts[:Authentication]
  #       ]
  #     }
  #   end
  # end
  #
  # module PrintMedia
  #   def self.opts
  #     {
  #       StandardPrint: [
  #         FGO::Medium.opts[:StandardPrint],
  #         FGO::Material.opts[:StandardMaterial],
  #         FG::Submedia.opts[:StandardSubmedia],
  #         FG::Authentication.opts[:Authentication]
  #       ],
  #
  #       PrintOnPaper: [
  #         FGO::Medium.opts[:PrintOnPaper],
  #         FSO::Material.opts[:Paper],
  #         FG::Submedia.opts[:SubmediaOnPaper],
  #         FG::Authentication.opts[:Authentication]
  #       ]
  #     }
  #   end
  # end
  #
  # module HandPulledPrint
  #   def self.opts
  #     {
  #       PrintOnPaper: [
  #         FGO::Medium.opts[:HandPulledPrintOnPaper],
  #         FSO::Material.opts[:Paper],
  #         FG::Submedia.opts[:SubmediaOnPaper],
  #         FG::Authentication.opts[:Authentication]
  #       ],
  #
  #       PrintOnCanvas: [
  #         FSO::Medium.opts[:HandPulledSilkscreen],
  #         FGO::Material.opts[:Canvas],
  #         FG::Submedia.opts[:StandardSubmedia],
  #         FG::Authentication.opts[:Authentication]
  #       ]
  #     }
  #   end
  # end

end
