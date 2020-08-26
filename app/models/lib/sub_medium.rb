class SubMedium
  include Context

  def self.tags
    tags_hsh(-2,-1)
  end

  #SFO
  class SFO < SubMedium
    def self.builder
      select_field(field_class_name, tags[:kind], options, tags)
    end

    class Embellishment < SFO
      class Embellished < Embellishment
        def self.options
          Option.builder(['hand embellished', 'hand painted', 'artist embellished'], tags[:kind], tags)
        end
      end

      class Colored < Embellishment
        def self.options
          Option.builder(['hand colored', 'hand watercolored', 'hand colored (pencil)', 'hand tinted'], tags[:kind], tags)
        end
      end
    end #end of SFO::Embellishment

    class Leafing < SFO
      class GoldLeaf < Leafing
        def self.options
          Option.builder(['goldleaf', 'hand laid goldleaf'], tags[:kind], tags)
        end
      end

      class SilverLeaf < Leafing
        def self.options
          Option.builder(['silverleaf', 'hand laid silverleaf'], tags[:kind], tags)
        end
      end
    end

    class Remarque < SFO
      def self.tags
        tags_hsh(-1,-1)
      end

      def self.options
        Option.builder(['remarque', 'hand drawn remarque', 'hand colored remarque', 'hand drawn and colored remarque'], tags[:kind], tags)
      end
    end
  end

  class SMO < SubMedium
    class Leafing < SMO
      def self.tags
        tags_hsh(-1,-1)
      end

      def self.builder
        select_menu(field_class_name, tags[:kind], [SFO::Leafing::GoldLeaf.builder, SFO::Leafing::SilverLeaf.builder], tags)
      end
    end
  end

  class RBF < SubMedium
    class HandPulled < RBF
      def self.tags
        tags_hsh(-1,-1)
      end

      def self.builder
        radio_button(field_class_name, tags[:kind], tags)
      end
    end
  end
end
