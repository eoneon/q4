class Submedium
  extend Context
  extend FieldKind

  def self.cascade_build(store)
    f_kind, f_type, f_name = f_attrs(0, 1, 3)
    add_field_group(to_class(f_type), self, f_type, f_kind, f_name, store)
  end

  class SelectField < Submedium

    class Embellishing < SelectField
      class StandardEmbellishing < Embellishing
        def self.targets
          ['hand embellished', 'hand painted', 'artist embellished']
        end
      end

      class PaperEmbellishing < Embellishing
        def self.targets
          ['hand embellished', 'hand painted', 'hand colored', 'hand watercolored', 'hand colored (pencil)', 'hand tinted']
        end
      end
    end

    class Leafing < SelectField
      class StandardLeafing < Leafing
        def self.targets
          ['gold leaf', 'hand laid gold leaf', 'silver leaf', 'hand laid silver leaf', 'hand laid gold and silver leaf', 'hand laid copper leaf']
        end
      end
    end

    class Remarque < SelectField
      class StandardRemarque < Remarque
        def self.targets
          ['remarque', 'hand drawn remarque', 'hand colored remarque', 'hand drawn and colored remarque']
        end
      end
    end

  end
end
