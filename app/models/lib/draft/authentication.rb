class Authentication
  include Context

  def self.field_kind
    slice_class(-1).underscore
  end

  class FSO < Authentication
    class Standard < FSO
      class SignatureAndCertificate < Standard
        def self.builder
          field_set(field_name, field_kind, [SFO::Standard::Signature.builder, SFO::Standard::Certificate.builder])
        end
      end
    end
  end

  class SFO < Authentication
    def self.builder
      select_field(field_name, field_kind, options)
    end
  end

  class Standard < SFO
    class Signature < Standard
      def self.options
        Option.builder(['hand signed', 'plate signed', 'authorized signature', 'estate signed'], field_kind)
      end
    end

    class Certificate < Standard
      def self.options
        Option.builder(['LOA', 'COA'], field_kind)
      end
    end
  end

end
