class PrintMedium
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.assocs
    {
      Authentication: [[:FieldSet, :StandardAuthentication]],
      Disclaimer: [[:FieldSet, :StandardDisclaimer]]
    }
  end

  class OnPaper < PrintMedium
    def self.assocs
      {Material: [[:FieldSet, :StandardPaper]]}
    end

    class GroupA < OnPaper
      def self.assocs
        {
          Category: [[:RadioButton, :ReproductionPrint]],
          Medium: [[:SelectField, :Poster]],
          Remarque: [[:SelectField, :StandardRemarque]]
        }
      end
    end

    class MixedMedia < OnPaper
      def self.assocs
        {Submedium: [[:FieldSet, :ReproductionOnPaper]]}
      end

      class GroupB < MixedMedia
        def self.assocs
          {
            Category: (end_keys(:RadioButton, :OneOfAKind, :ReproductionPrint) + end_keys(:FieldSet, :LimitedEdition, :UniqueVariation, :OneOfAKindOfOne)),
            Medium: end_keys(:SelectField, :StandardSerigraph, :HandPulledSerigraph, :StandardEtching, :StandardGiclee, :StandardRelief, :StandardMixedMedia)
          }
        end
      end

      class GroupC < MixedMedia
        def self.assocs
          {
            Category: ([[:RadioButton, :ReproductionPrint]] + end_keys(:FieldSet, :LimitedEdition, :UniqueVariation)),
            Medium: end_keys(:SelectField, :StandardLithograph, :HandPulledLithograph, :Seriolithograph, :StandardPrint)
          }
        end
      end

      class GroupD < MixedMedia
        def self.assocs
          {
            Category: [[:RadioButton, :OneOfAKind], [:FieldSet, :OneOfAKindOfOne]],
            Medium: [[:SelectField, :Monotype]]
          }
        end
      end
    end
  end

  class OnCanvas < PrintMedium
    def self.assocs
      {
        Material: end_keys(:FieldSet, :StandardCanvas, :WrappedCanvas),
        Submedium: [[:FieldSet, :ReproductionOnStandard]]
      }
    end

    class GroupE < OnCanvas
      def self.assocs
        {
          Category: (end_keys(:RadioButton, :OneOfAKind, :ReproductionPrint) + end_keys(:FieldSet, :LimitedEdition, :UniqueVariation, :OneOfAKindOfOne)),
          Medium: end_keys(:SelectField, :StandardSerigraph, :HandPulledSerigraph, :StandardGiclee, :StandardMixedMedia)
        }
      end
    end
  end

  class OnOther < PrintMedium
    def self.assocs
      {
        Material: end_keys(:FieldSet, :StandardBoard, :Wood, :WoodBox, :Acrylic, :StandardMetal, :MetalBox),
        Submedium: [[:FieldSet, :ReproductionOnStandard]]
      }
    end

    class GroupF < OnOther
      def self.assocs
        {
          Category: ([[:RadioButton, :ReproductionPrint]] + end_keys(:FieldSet, :LimitedEdition, :UniqueVariation)),
          Medium: end_keys(:SelectField, :StandardSerigraph, :StandardGiclee, :StandardMixedMedia)
        }
      end
    end
  end

  class OneOfAKind < PrintMedium
    def self.assocs
      {
        Category: [[:RadioButton, :OneOfAKind], [:FieldSet, :OneOfAKindOfOne]],
        Medium: [[:SelectField, :AcrylicMixedMedia]],
        Material: end_keys(:FieldSet, :StandardCanvas, :WrappedCanvas, :StandardPaper)
      }
    end
  end
end
