class Submedium
  include ClassContext
  include FieldSeed
  include Hashable

  def self.builder(store)
    args = build_attrs(:attrs)
    add_field_group(to_class(args[:type]), self, args[:type], args[:kind], args[:f_name], store)
  end

  def self.attrs
    {kind: 2, type: 1, f_name: -1}
  end

  def self.assoc_group
    #kind, type = [:kind,:type].map{|k| build_attrs(:attrs)[k].to_sym}
    merge_enum(:targets, :set)
  end

  class SelectField < Submedium

    def self.assoc_group
      #kind, type = [:kind,:type].map{|k| build_attrs(:attrs)[k].to_sym}
      merge_enum(:targets, :set)
    end

    class Embellishing < SelectField
      class StandardEmbellishing < Embellishing
        def self.set
          [:StandardSubmedia]
        end

        def self.targets
          ['hand embellished', 'hand painted', 'artist embellished']
        end
      end

      class PaperEmbellishing < Embellishing
        def self.set
          [:PaperSubmedia]
        end

        def self.targets
          ['hand embellished', 'hand painted', 'hand colored', 'hand watercolored', 'hand colored (pencil)', 'hand tinted']
        end
      end
    end

    class Leafing < SelectField
      class StandardLeafing < Leafing
        def self.set
          [:PaperSubmedia]
        end

        def self.targets
          ['gold leaf', 'hand laid gold leaf', 'silver leaf', 'hand laid silver leaf', 'hand laid gold and silver leaf', 'hand laid copper leaf']
        end
      end
    end

    class Remarque < SelectField
      class StandardRemarque < Remarque
        def self.set
          [:PaperSubmedia]
        end

        def self.targets
          ['remarque', 'hand drawn remarque', 'hand colored remarque', 'hand drawn and colored remarque']
        end
      end
    end

  end
end

# def self.cascade_build(store)
#   f_kind, f_type, f_name = f_attrs(0, 1, 3)
#   add_field_group(to_class(f_type), self, f_type, f_kind, f_name, store)
# end
