class SubMedium
  include Context

  def self.field_kind
    slice_class(-1).underscore
  end

  class FSO < SubMedium
    class OnPaper < FSO
      class LeafingAndRemarque < OnPaper
        def self.builder
          field_set(field_name, field_kind, [SFO::OnPaper::Leafing.builder, SFO::OnPaper::Remarque.builder])
        end
      end
    end
  end

  class SFO < SubMedium
    def self.builder
      select_field(field_name, field_kind, options)
    end

    class OnPaper < SFO
      class Embellished < OnPaper
        def self.field_name
          'embellished (o/p)'
        end

        def self.options
          Option.builder(['hand embellished', 'hand painted', 'hand colored', 'hand watercolored', 'hand colored (pencil)', 'hand tinted'], field_kind)
        end
      end

      class Leafing < OnPaper
        def self.options
          Option.builder(['gold leaf', 'hand laid gold leaf', 'silver leaf', 'hand laid silver leaf', 'hand laid gold and silver leaf', 'hand laid copper leaf'], field_kind)
        end
      end

      class Remarque < OnPaper
        def self.options
          Option.builder(['remarque', 'hand drawn remarque', 'hand colored remarque', 'hand drawn and colored remarque'], field_kind)
        end
      end
    end

    class Standard < SFO
      class Embellished < Standard
        def self.options
          Option.builder(['hand embellished', 'hand painted', 'artist embellished'], field_kind)
        end
      end
    end
  end

  class RBF < SubMedium
    class HandPulled < RBF
      def self.builder
        radio_button(field_name, field_kind)
      end
    end
  end
end
