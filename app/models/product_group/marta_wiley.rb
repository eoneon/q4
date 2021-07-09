class MartaWiley
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.product_name
    class_to_cap(const(0))
  end

  def self.assocs
    {
      Category: [[:RadioButton, :StandardOriginal]],
      Authentication: [[:FieldSet, :WileyAuthentication]],
      Disclaimer: [[:FieldSet, :StandardDisclaimer]]
    }
  end

  class GroupA < MartaWiley
    def self.assocs
      {
        Medium: end_keys(:SelectField, :AcylicPainting, :MixedMediaPainting, :StandardMixedMedia,),
        Material: ([[:FieldSet, :StandardPaper]] + end_keys(:FieldSet, :StandardCanvas, :WrappedCanvas))}
    end
  end

  class GroupB < MartaWiley
    def self.assocs
      {
        Medium: end_keys(:SelectField, :MixedMediaPencilDrawing, :MixedMediaPenAndInkDrawing),
        Material: [[:FieldSet, :StandardPaper]]
      }
    end
  end

end
