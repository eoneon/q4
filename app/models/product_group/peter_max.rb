class PeterMax
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.product_name
    class_to_cap(const)
  end

  def self.assocs
    {
      Material: [[:FieldSet, :StandardPaper]],
      Authentication: [[:FieldSet, :PeterMaxAuthentication]],
      Disclaimer: [[:FieldSet, :StandardDisclaimer]]
    }
  end

  class OneOfAKind < PeterMax
    def self.assocs
      {
        Category: [[:RadioButton, :OneOfAKind]],
        Medium: [[:SelectField, :AcrylicMixedMedia]]
      }
    end
  end

  class LimitedEdition < PeterMax
    def self.assocs
      {
        Category: [[:FieldSet, :LimitedEdition]],
        Medium: end_keys(:SelectField, :StandardLithograph, :StandardEtching)
      }
    end
  end
end
