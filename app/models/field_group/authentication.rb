class Authentication
  include ClassContext
  include FieldSeed
  include Hashable

  def self.builder(store)
    args = build_attrs(:attrs)
    add_field_group(to_class(args[:type]), self, args[:type], args[:kind], args[:f_name], store)
  end

  def self.attrs
    {kind: 2, type: 1, f_name: -1}
  end

  class SelectField < Authentication

    def self.assoc_group
      kind, type = [:kind,:type].map{|k| build_attrs(:attrs)[k].to_sym}
      merge_groups.each_with_object({}) do |(k,v), assocs|
        case_merge(assocs, k, v, kind, type)
      end
    end

    class Signature < SelectField
      class StandardSignature < Signature
        def self.set
          [:StandardAuthentication, :PeterMaxAuthentication, :BrittoAuthentication]
        end

        def self.targets
          ['hand signed', 'plate signed', 'authorized signature', 'estate signed', 'unsigned']
        end
      end
    end

    class Certificate < SelectField
      class StandardCertificate < Certificate
        def self.set
          [:StandardAuthentication]
        end

        def self.targets
          ['LOA', 'COA']
        end
      end

      class PeterMaxCertificate < Certificate
        def self.set
          [:PeterMaxAuthentication]
        end

        def self.targets
          ['LOA', 'COA from Peter Max Studios']
        end
      end

      class BrittoCertificate < Certificate
        def self.set
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

# class FieldSet < Authentication
#
#   class Standard < FieldSet
#     class StandardAuthentication < Standard
#     end
#   end
# end
  #f_type, f_kind, f_name = [1, 2, 3].map{|i| const_tree[i]}

  # def self.cascade_build(class_a, class_b, class_c, class_d, store)
  #   f_type, f_kind, f_name = [class_b, class_c, class_d].map(&:const)
  #   add_field_group(to_class(f_type), class_d, f_type, f_kind, f_name, store)
  # end

  # def self.cascade_build(store, class_set)
  #   f_type, f_kind, f_name = class_set[1..-1].map(&:const)
  #   puts "class_set: #{class_set}"
  #   add_field_group(to_class(f_type), class_set[-1], f_type, f_kind, f_name, store)
  # end
