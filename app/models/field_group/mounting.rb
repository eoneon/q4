class Mounting
  include ClassContext
  include FieldSeed
  include Hashable

  def self.attrs
    {kind: 0, type: 1, field_name: -1}
  end

  def self.merge_related_params(input_group, f, args)
  	if v = f.tags[args[1]]
  		Item.case_merge(input_group[:d_hsh], v, *args)
  		mounting_search_params(input_group[:d_hsh], f.tags, args[0])
  	end
  end

  def self.mounting_search_params(d_hsh, tags, k, sub_key='mounting_search')
  	if v = tags[sub_key]
  		Item.case_merge(d_hsh, v, k, sub_key)
  	end
  end

  class SelectField < Mounting
    def self.target_tags(f_name)
      {mounting_search: f_name.split(' ').map(&:capitalize).join(' ')}
    end

    class Framing < SelectField
      def self.target_tags(f_name)
        {tagline: 'Framed', body: body(f_name), mounting_dimension: '(frame)', mounting_search: f_name.split(' ').map(&:capitalize).join(' ')}
      end

      def self.body(f_name)
        if f_name.split(' ').include?('(floated)');
          "This piece comes floating in a #{f_name}."
        elsif f_name.split(' ').include?('box');
          "This piece comes in a #{f_name}."
        elsif f_name.split(' ').include?('oversized');
          "This piece has an #{f_name}."
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
    end
  end
end
