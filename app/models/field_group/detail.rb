class Detail
  include ClassContext
  include FieldSeed
  include Hashable

  def self.builder(store)
    field_group(:targets, store)
  end

  def self.attrs
    {kind: 2, type: 1, f_name: -1}
  end

  class RadioButton < Detail

    class TextBeforeCOA < RadioButton
      class Everhart < TextBeforeCOA
        def self.field_value(args)
          "This is one of the final Everhart editions to be created on a rare, antique Marinoni Voirin lithograph press that dates back to the 1800's."
        end

        def self.targets
        end
      end

      class SingleExposure < TextBeforeCOA
        def self.field_value(args)
          "This piece was created using a single-exposure over time in which the artist walks into the shot creating figures on film; no photoshop or digital manipulation is involved."
        end

        def self.targets
        end
      end
    end

    class TextAfterTitle < RadioButton
      class Ikebana < TextAfterTitle
        def self.field_value(args)
          "sculpture features a secured Kenzan spiked disc inside - the key to any fine Ikebana style flower arrangement"
        end

        def self.targets
        end
      end

      class Primitive < TextAfterTitle
        def self.field_value(args)
          "sculpture combines sand-etched exteriors with a glossy interior"
        end

        def self.targets
        end
      end

      class SaturnLamp < TextAfterTitle
        def self.field_value(args)
          "features a fiberglass wick to get you started, and when lit, the lamp casts a glowing ring of firelight, evoking the rings of majestic Saturn"
        end
      end

      class Arbor < TextAfterTitle
        def self.field_value(args)
          "integrates striking colors with graceful curves"
        end

        def self.targets
        end
      end

      class OpenBowlVase < TextAfterTitle
        def self.field_value(args)
          "combines sand-etched exteriors with an elegant lip accent"
        end

        def self.targets
        end
      end

      class CoveredBowlVase < TextAfterTitle
        def self.field_value(args)
          "sculpture combines sand-etched exteriors with an elegant"
        end

        def self.targets
        end
      end
    end
  end
end


# def self.cascade_build(store)
#   f_type, f_kind, f_name = f_attrs(1, 2, 3)
#   add_field_group(to_class(f_type), self, f_type, f_kind, f_name, store, {'field_value(args)' => field_value(args)})
# end

# def self.cascade_build(class_a, class_b, class_c, class_d, store)
#   f_type, f_kind, f_name = [class_b, class_c, class_d].map(&:const)
#   add_field_group(to_class(f_type), class_d, f_type, f_kind, f_name, store, {'field_value(args)' =>class_d.field_value(args)})
# end
