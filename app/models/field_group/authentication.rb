class Authentication
  include ClassContext
  include FieldSeed
  include Hashable

  def self.attrs
    {kind: 2, type: 1, f_name: -1}
  end

  class SelectField < Authentication
    class Dated < SelectField
      class StandardDated < Dated
        def self.targets
          ['Dated', 'Dated Circa']
        end
      end
    end

    class Signature < SelectField
      class StandardSignature < Signature
        def self.targets
          ['hand signed', 'hand signed inverso', 'plate signed', 'authorized signature', 'estate signed', 'unsigned']
        end
      end

      class WileySignature < Signature
        def self.targets
          ['hand signed and thumbprinted', 'hand signed', 'hand signed inverso', 'unsigned']
        end
      end
    end

    class Certificate < SelectField
      class StandardCertificate < Certificate
        def self.targets
          ['LOA', 'COA']
        end
      end

      class PeterMaxCertificate < Certificate
        def self.targets
          ['LOA', 'COA from Peter Max Studios']
        end
      end

      class BrittoCertificate < Certificate
        def self.targets
          ['LOA', 'COA from Britto Rommero fine art', 'official Britto Stamp inverso']
        end
      end
    end

    class Seal < SelectField
      class AnimationSeal < Seal
        def self.targets
          ['Warner Bros.', 'Looney Tunes']
        end
      end

      class SportsSeal < Seal
        def self.targets
          ['MLB', 'NFL', 'NBA', 'NHL']
        end
      end
    end
  end

  class TextField < Authentication
    class Verification < TextField
      class RegistrationNumber < Verification
        def self.targets
        end
      end
    end

    class Dated < TextField
      class StandardDated < Dated
        def self.targets
        end
      end
    end
  end

  class FieldSet < Authentication
    class Dated < FieldSet
      class StandardDated < Dated
        def self.targets
          [%W[SelectField Dated StandardDated], %W[TextField Dated StandardDated]]
        end
      end
    end

    class Seal < FieldSet
      class AnimationSeal < Seal
        def self.targets
          [%W[SelectField Seal AnimationSeal], %W[SelectField Seal SportsSeal]]
        end
      end
    end

    class GroupA < FieldSet
      def self.attrs
        {kind: 0}
      end

      class StandardAuthentication < GroupA
        def self.targets
          [%W[FieldSet Dated StandardDated], %W[SelectField Signature StandardSignature], %W[SelectField Certificate StandardCertificate]]
        end
      end

      class PeterMaxAuthentication < GroupA
        def self.targets
          [%W[TextField Verification RegistrationNumber], %W[SelectField Signature StandardSignature], %W[SelectField Certificate PeterMaxCertificate]]
        end
      end

      class BrittoAuthentication < GroupA
        def self.targets
          [%W[SelectField Signature StandardSignature], %W[SelectField Certificate BrittoCertificate]]
        end
      end

      class WileyAuthentication < GroupA
        def self.targets
          [%W[SelectField Signature WileySignature], %W[SelectField Certificate StandardCertificate]]
        end
      end

      class StandardSericelAuthentication < GroupA
        def self.targets
          [%W[SelectField Signature StandardSignature], %W[FieldSet Seal AnimationSeal], %W[SelectField Certificate StandardCertificate]]
        end
      end

      class SericelAuthentication < GroupA
        def self.targets
          [%W[FieldSet Dated StandardDated], %W[SelectField Signature StandardSignature], %W[SelectField Seal AnimationSeal], %W[SelectField Certificate StandardCertificate]]
        end
      end
    end
  end
end
