class OriginalMedium
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.assocs
    {
      Category: [[:RadioButton, :StandardOriginal]],
      Authentication: [[:FieldSet, :StandardAuthentication]],
      Disclaimer: [[:FieldSet, :StandardDisclaimer]]
    }
  end

  class OnPaper < OriginalMedium
    def self.assocs
      {Material: [[:FieldSet, :StandardPaper]]}
    end

    class GroupA < OnPaper
      def self.assocs
        {Medium: end_keys(:SelectField, :WatercolorPainting, :PastelPainting, :GuachePainting, :PencilDrawing, :PenAndInkDrawing)}
      end
    end

    class GroupB < OnPaper
      def self.assocs
        {
          Medium: end_keys(:SelectField, :MixedMediaPencilDrawing, :MixedMediaPenAndInkDrawing),
          Submedium: [[:FieldSet, :OriginalOnPaper]]
        }
      end
    end
  end

  class OnStandard < OriginalMedium
    def self.assocs
      {
        Medium: end_keys(:SelectField, :OilPainting, :AcylicPainting, :MixedMediaPainting, :UnknownPainting),
        Material: end_keys(:FieldSet, :StandardPaper, :StandardCanvas, :WrappedCanvas, :StandardBoard, :Wood, :WoodBox, :Acrylic, :StandardMetal, :MetalBox)
      }
    end
  end
end
