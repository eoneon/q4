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

# def self.cascade_build(store)
#   f_type, f_kind, f_name = f_attrs(1, 2, 3)
#   add_field_group(to_class(f_type), self, f_type, f_kind, f_name, store)
# end

# class Fieldassocs < Authentication
#
#   class Standard < Fieldassocs
#     class StandardAuthentication < Standard
#     end
#   end
# end
  #f_type, f_kind, f_name = [1, 2, 3].map{|i| const_tree[i]}

  # def self.cascade_build(class_a, class_b, class_c, class_d, store)
  #   f_type, f_kind, f_name = [class_b, class_c, class_d].map(&:const)
  #   add_field_group(to_class(f_type), class_d, f_type, f_kind, f_name, store)
  # end

  # def self.cascade_build(store, class_assocs)
  #   f_type, f_kind, f_name = class_assocs[1..-1].map(&:const)
  #   puts "class_assocs: #{class_assocs}"
  #   add_field_group(to_class(f_type), class_assocs[-1], f_type, f_kind, f_name, store)
  # end
