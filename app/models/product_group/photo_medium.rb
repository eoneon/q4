class PhotoMedium
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.assocs
    {
      Category: [[:RadioButton, :ReproductionPrint], [:FieldSet, :LimitedEdition]],
      Medium: end_keys(:SelectField, :StandardPhotograph, :SportsPhotograph, :ConcertPhotograph, :PressPhotograph),
      Material: [[:FieldSet, :PhotoPaper]],
      Authentication: [[:FieldSet, :StandardAuthentication]],
      Disclaimer: [[:FieldSet, :StandardDisclaimer]]
    }
  end
end
