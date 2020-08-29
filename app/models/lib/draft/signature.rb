class Signature
  include Context

  def self.tags
    tags_hsh(0,-1)
  end

  def self.field_name
    "#{field_name} signature"
  end

  class Standard < Signature
    def self.builder
      select_field(field_name, field_kind, SFO::Standard.builder, tags)
    end
  end

  class SFO < Signature
    class Standard < SFO
      def self.builder
        Option.builder(['hand signed', 'plate signed', 'authorized signature', 'estate signed'], field_kind, tags)
      end
    end
  end
end
