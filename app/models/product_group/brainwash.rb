class Brainwash
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.product_name
    'Brainwash'
  end

  def self.assocs
    {
      Medium: [[:SelectField, :StandardMixedMedia]],
      Material: [[:FieldSet, :StandardPaper]],
      Authentication: [[:FieldSet, :StandardAuthentication]],
      Disclaimer: [[:FieldSet, :StandardDisclaimer]]
    }
  end

  class GroupA < Brainwash
    def self.assocs
      {Category: [[:RadioButton, :StandardOriginal]]}
    end
  end

  class GroupB < Brainwash
    def self.assocs
      {Category: [[:RadioButton, :Unique]]}
    end
  end

end
