class Sculpture
  extend Context
  extend FieldKind

  def self.cascade_build(class_a, class_b, class_c, class_d, store)
    f_type, f_kind, f_name = [class_b, class_c, class_d].map(&:const)
    add_field_group(to_class(f_type), class_d, f_type, f_kind, f_name, store)
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
