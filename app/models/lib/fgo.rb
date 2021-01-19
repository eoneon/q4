module FGO
  extend Build
  # h = FGO.field_groups(PRD.seed_fields)
  # def self.field_groups(store)
  #   constants.each do |kind|
  #     modulize(self,kind).opts.each do |fgo_key, field_keys|
  #       targets = merge_fgo(kind, field_keys, store)
  #       params_merge(params: store, dig_set: dig_set(fgo_key, targets, :FGO, kind))
  #     end
  #   end
  #   store
  # end
  #
  # def self.merge_fgo(kind, field_keys, store, targets=[])
  #   field_keys.each do |field_key|
  #     targets << store.dig(:FieldSet, kind, field_key)
  #   end
  #   targets.flatten
  # end FGO::Material.opts[:StandardMaterial]

  module Material
    def self.opts
      {
        StandardMaterial: FGO.build_key_group([:Canvas, :WrappedCanvas, :Paper, :Wood, :WoodBox, :Metal, :MetalBox, :Acrylic], :FieldSet, :Material),
        Canvas: FGO.build_key_group([:Canvas, :WrappedCanvas], :FieldSet, :Material),
        Paper: FGO.build_key_group([:Paper], :FieldSet, :Material),
        PhotoPaper: FGO.build_key_group([:PhotoPaper], :FieldSet, :Material),
        AnimaPaper: FGO.build_key_group([:AnimaPaper], :FieldSet, :Material)
      }
    end
  end

  # module Medium
  #   def self.opts
  #     {
  #       OneOfAKindMixedMediaOnPaper: [:AcrylicMixedMedia, :Monotype].map{|k| SFO::Medium.opts[k]},
  #       #OneOfAKindMixedMediaOnCanvas:,
  #
  #       #MixedMediaOnPaper: [:BasicMixedMedia, :Etching, :Relief].map{|k| SFO::Medium.opts[k]},
  #       #MixedMediaOnCanvas: [:AcrylicMixedMedia, :BasicMixedMedia].map{|k| SFO::Medium.opts[k]},
  #
  #       HandPulledPrintOnPaper: [:HandPulledSilkscreen, :HandPulledLithograph].map{|k| SFO::Medium.opts[k]},
  #       #HandPulledPrintOnCanvas: ,
  #       StandardPrint: [:Silkscreen, :Giclee, :BasicMixedMedia, :BasicPrint].map{|k| SFO::Medium.opts[k]},
  #       PrintOnPaper: [:Lithograph, :Etching, :Relief, :Seriolithograph].map{|k| SFO::Medium.opts[k]}
  #       #BasicPrintOnPaper: SFO::Medium.opts[:Poster],
  #     }
  #   end
  # end

end
