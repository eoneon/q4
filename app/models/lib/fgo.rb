module FGO

  module Material
    def self.opts
      {
        StandardMaterial: [:Canvas, :WrappedCanvas, :Paper, :Wood, :WoodBox, :Metal, :MetalBox, :Acrylic].map{|k| FSO::Material.opts[k]},
        Canvas: [:Canvas, :WrappedCanvas].map{|k| FSO::Material.opts[k]},
        Paper: FSO::Material.opts[:Paper],
        PhotoPaper: FSO::Material.opts[:PhotoPaper],
        AnimaPaper: FSO::Material.opts[:AnimaPaper]
      }
    end
  end

  module Medium
    def self.opts
      {
        OneOfAKindMixedMediaOnPaper: [:AcrylicMixedMedia, :Monotype].map{|k| SFO::Medium.opts[k]},
        #OneOfAKindMixedMediaOnCanvas:,

        #MixedMediaOnPaper: [:BasicMixedMedia, :Etching, :Relief].map{|k| SFO::Medium.opts[k]},
        #MixedMediaOnCanvas: [:AcrylicMixedMedia, :BasicMixedMedia].map{|k| SFO::Medium.opts[k]},

        HandPulledPrintOnPaper: [:HandPulledSilkscreen, :HandPulledLithograph].map{|k| SFO::Medium.opts[k]},
        #HandPulledPrintOnCanvas: ,
        StandardPrint: [:Silkscreen, :Giclee, :BasicMixedMedia, :BasicPrint].map{|k| SFO::Medium.opts[k]},
        PrintOnPaper: [:Lithograph, :Etching, :Relief, :Seriolithograph].map{|k| SFO::Medium.opts[k]}
        #BasicPrintOnPaper: SFO::Medium.opts[:Poster],
      }
    end
  end

end
