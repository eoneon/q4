class Authentication
  include ClassContext
  include FieldSeed
  include Hashable

  def self.attrs
    {kind: 2, type: 1, f_name: -1}
  end

  class SelectField < Authentication

    class Signature < SelectField
      class StandardSignature < Signature
        def self.assocs
          [:StandardAuthentication, :PeterMaxAuthentication, :BrittoAuthentication]
        end

        def self.targets
          ['hand signed', 'plate signed', 'authorized signature', 'estate signed', 'unsigned']
        end
      end
    end

    class Certificate < SelectField
      class StandardCertificate < Certificate
        def self.assocs
          [:StandardAuthentication]
        end

        def self.targets
          ['LOA', 'COA']
        end
      end

      class PeterMaxCertificate < Certificate
        def self.assocs
          [:PeterMaxAuthentication]
        end

        def self.targets
          ['LOA', 'COA from Peter Max Studios']
        end
      end

      class BrittoCertificate < Certificate
        def self.assocs
          [:BrittoAuthentication]
        end

        def self.targets
          ['LOA', 'COA from Britto Rommero fine art', 'official Britto Stamp inverso']
        end
      end
    end

  end

end
