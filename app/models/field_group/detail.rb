class Detail
  include ClassContext
  include FieldSeed
  include Hashable

  def self.attrs
    {kind: 2, type: 1, f_name: -1}
  end

  class RadioButton < Detail
    class TextBeforeCOA < RadioButton
      class Everhart < TextBeforeCOA
        def self.name_values
          {body: "This is one of the final Everhart editions to be created on a rare, antique Marinoni Voirin lithograph press that dates back to the 1800's."}
        end

        def self.targets
        end
      end

      class SingleExposure < TextBeforeCOA
        def self.name_values
          {body: "This piece was created using a single-exposure over time in which the artist walks into the shot creating figures on film; no photoshop or digital manipulation is involved."}
        end

        def self.targets
        end
      end
    end
  end
end
