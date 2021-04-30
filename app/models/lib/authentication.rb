class Authentication
  extend Context
  extend FieldKind

  def self.cascade_build(class_a, class_b, class_c, class_d, store)
    f_type, f_kind, f_name = [class_b, class_c, class_d].map(&:const)
    add_field_group(to_class(f_type), class_d, f_type, f_kind, f_name, store)
  end

  class SelectField < Authentication

    class Signature < SelectField
      class StandardSignature < Signature
        def self.targets
          ['hand signed', 'plate signed', 'authorized signature', 'estate signed', 'unsigned']
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

  end
end
