class Everhart
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.product_name
    'Everhart'
  end

  def self.assocs
    {
      Category: [[:FieldSet, :LimitedEdition]],
      Medium: [[:SelectField, :StandardLithograph]],
      Material: [[:FieldSet, :StandardPaper]],
      TextBeforeCOA: [[:RadioButton, :Everhart]],
      Authentication: [[:FieldSet, :StandardAuthentication]],
      Disclaimer: [[:FieldSet, :StandardDisclaimer]]
    }
  end
end
