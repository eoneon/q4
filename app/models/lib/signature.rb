class Signature
  include Context

  def self.tags
    tags_hsh(0,-1)
  end

  class Standard < Signature
    def self.builder
      select_field(field_name, field_kind, Option.builder(['hand signed', 'plate signed', 'authorized signature', 'estate signed']), tags)
    end
  end
end
