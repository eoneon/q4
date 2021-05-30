class Sculpture
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

  class SelectField < Sculpture

    class SculptureType < SelectField
      class Bowl < SculptureType
        def self.targets
          ['bowl', 'covered bowl']
        end
      end

      class Vase < SculptureType
        def self.targets
          ['vase', 'flat vessel', 'jar']
        end
      end

      class Sculpture < SculptureType
        def self.targets
          ['sculpture']
        end
      end
    end

  end
end



# def self.cascade_build(store)
#   f_kind, f_type, f_name = f_attrs(0, 1, 3)
#   add_field_group(to_class(f_type), self, f_type, f_kind, f_name, store)
# end
