class Sculpture
  include ClassContext
  include FieldSeed
  include Hashable

  def self.builder(store)
    field_group(:targets, store)
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
