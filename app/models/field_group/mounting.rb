class Mounting
  include ClassContext
  include FieldSeed
  include Hashable

  def self.attrs
    {kind: 0, type: 1, f_name: -1}
  end

  class SelectField < Mounting
    class Framing < SelectField
      def self.target_tags(f_name)
        {tagline: 'Framed', body: body(f_name), mounting_dimension: '(frame)'}
      end

      def self.body(f_name)
        if f_name.split(' ').include?('(floated)');
          "This piece comes floating in a #{f_name}."
        elsif f_name.split(' ').include?('box');
          "This piece comes in a #{f_name}."
        else
          "This piece comes #{f_name+'d'}."
        end
      end

      class StandardFraming < Framing
        def self.targets
          ['frame', 'frame (floated)', 'custom frame', 'custom frame (floated)', 'box frame', 'simple box frame']
        end
      end
    end

    class Matting < SelectField
      def self.target_tags(f_name)
        {body: "This piece comes matted.", mounting_dimension: '(matting)'}
      end

      class StandardMatting < Matting
        def self.targets
          ['matted']
        end
      end
    end

    class Border < SelectField
      def self.target_tags(f_name)
        {mounting_dimension: '(border)'}
      end

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
        def self.targets
          build_target_group(%W[StandardFraming StandardMatting StandardBorder], 'FieldSet', 'Mounting')
        end
      end

      class CanvasMounting < FlatMounting
        def self.targets
          build_target_group(%W[StandardFraming StandardMatting], 'FieldSet', 'Mounting')
        end
      end

      class SericelMounting < FlatMounting
        def self.targets
          build_target_group(%W[StandardFraming StandardMatting], 'FieldSet', 'Mounting')
        end
      end
    end
  end
end
