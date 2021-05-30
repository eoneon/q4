class Mounting
  include ClassContext
  include FieldSeed
  include Hashable

  def self.builder(store)
    args = build_attrs(:attrs)
    add_field_group(to_class(args[:type]), self, args[:type], args[:kind], args[:f_name], store)
  end

  def self.attrs
    {kind: 0, type: 1, f_name: -1}
  end

  class SelectField < Mounting

    class Framing < SelectField
      class StandardFraming < Framing
        def self.targets
          ['framed', 'custom framed', 'box frame', 'simple box frame']
        end
      end
    end

    class Matting < SelectField
      class StandardMatting < Matting
        def self.targets
          ['matted']
        end
      end
    end

    class Border < SelectField
      class StandardBorder < Border
        def self.targets
          ['border', 'oversized border']
        end
      end
    end

  end

  class FieldSet < Mounting
    class FlatMounting < FieldSet
      class StandardFraming < FlatMounting
        def self.targets
          [%W[SelectField Mounting StandardFraming], %W[FieldSet Dimension MountingWidthHeight]]
        end
      end

      class StandardMatting < FlatMounting
        def self.targets
          [%W[SelectField Mounting StandardMatting], %W[FieldSet Dimension MountingWidthHeight]]
        end
      end

      class StandardBorder < FlatMounting
        def self.targets
          [%W[SelectField Mounting StandardBorder], %W[FieldSet Dimension MountingWidthHeight]]
        end
      end
    end
  end

  class SelectMenu < Mounting
    class FlatMounting < SelectMenu
      class StandardMounting < FlatMounting
        build_target_group(%W[StandardFraming StandardMatting StandardBorder], 'FieldSet', 'Mounting')
      end

      class CanvashMounting < FlatMounting
        build_target_group(%W[StandardFraming StandardMatting], 'FieldSet', 'Mounting')
      end

      class SericelMounting < FlatMounting
        build_target_group(%W[StandardFraming StandardMatting], 'FieldSet', 'Mounting')
      end
    end
  end
end

# def self.cascade_build(store)
#   f_kind, f_type, f_name = f_attrs(0, 1, 3)
#   add_field_group(to_class(f_type), self, f_type, f_kind, f_name, store)
# end
