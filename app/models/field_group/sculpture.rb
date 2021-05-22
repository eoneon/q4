class Sculpture
  include ClassContext
  include FieldSeed

  def self.cascade_build(store)
    f_kind, f_type, f_name = f_attrs(0, 1, 3)
    add_field_group(to_class(f_type), self, f_type, f_kind, f_name, store)
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
