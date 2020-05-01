# module Pop
#
#   # class MenuGroup
#   #   def i_hsh
#   #     h={i_type: nil, i_name: nil, i_set: []}
#   #   end
#   #
#   #   def target_hsh(set)
#   #     h={name_key(set[0]) => set[1]}
#   #   end
#   #
#   #   def name_key(klass_name)
#   #     klass_name.classify.superclass.underscore
#   #   end
#   # end
#
#   module Category
#     module SelectValues
#       def self.set
#         #['painting', 'oil', 'acrylic', 'mixed media']
#       end
#     end
#   end
#
#   module Medium
#
#     module Painting
#       module SelectValues
#         def self.set
#           ['painting', 'oil', 'acrylic', 'mixed media']
#         end
#       end
#
#       # module MenuSet
#       # end
#     end
#
#     module PaintingOnPaper
#       module SelectValues
#         def self.set
#           ['watercolor', 'pastel', 'guache', 'sumi ink']
#         end
#       end
#     end
#
#   end
#
#   ##################################
#
#   module Material
#     module Canvas
#       module SelectValues
#         def self.set
#           ['canvas', 'canvas board', 'textured canvas']
#         end
#       end
#     end
#
#     module Paper
#       module SelectValues
#         def self.set
#           ['paper', 'deckle edge paper', 'rice paper', 'arches paper', 'sommerset paper', 'mother of pearl paper']
#         end
#       end
#     end
#
#
#     module PhotographyPaper
#       module SelectValues
#         def self.set
#           ['paper', 'photography paper', 'archival grade paper']
#         end
#       end
#     end
#
#     module AnimationPaper
#       module SelectValues
#         def self.set
#         ['paper', 'animation paper']
#       end
#     end
#   end
#
#   ##################################
#
#   module Mounting
#     module Canvas
#       module SelectValues
#         def self.set
#           ['framed', 'custom framed', 'matted']
#         end
#       end
#     end
#
#     module Paper
#       module SelectValues
#         def self.set
#           ['framed', 'custom framed', 'bordered', 'matted']
#         end
#       end
#     end
#   end
#
# end
# class MenuGroup
#   include Context
#
#   def i_hsh
#     h={i_type: nil, i_name: nil, i_set: []}
#   end
#
#   def target_hsh(set)
#     h={name_key(set[0]) => set[1]}
#   end
#
#   def name_key(klass_name)
#     file_names("item_field").include?(klass_name)
#   end
#
#   ############################################
#
#   class FieldItem
#     def self.attrs_hsh(name, f_set=[])
#       h={attrs: {type: klass_name, field_name: f_name(klass_name, name)}, f_set: f_set}
#     end
#
#     def self.f_name(klass_name, name)
#       if name_suffix = name_suffix(klass_name)
#         [name, name_suffix].join("-")
#       else
#         name
#       end
#     end
#
#     def self.name_suffix(klass_name)
#       if klass_name == 'FieldSet'
#         'field-set'
#       elsif klass_name == 'SelectField'
#         'type'
#       end
#     end
#
#     #mix item_fields and product_items #########################################
#     # module FieldGroup
#     #   def self.f_hsh(name, f_set)
#     #     attrs_hsh(name, FieldSetFields.f_set(f_set))
#     #   end
#     #   #f_set: [SelectField.f_hsh(name, f_set), Properties::NumberField.f_hsh(name1), Properties::NumberField.f_hsh(name2)]
#     #   module FieldSetFields
#     #     def self.f_set(f_set)
#     #       f_set.map{|f_subset| f_subset}
#     #     end
#     #   end
#     #
#     # end
#
#     module FieldSet
#       def self.f_hsh(name, f_set)
#         attrs_hsh(name, FieldSetFields.f_set(f_set))
#       end
#       #f_set: [SelectField.f_hsh(name, f_set), Properties::NumberField.f_hsh(name1), Properties::NumberField.f_hsh(name2)]
#       module FieldSetFields
#         def self.f_set(f_set)
#           f_set.map{|f_subset| f_subset}
#         end
#       end
#
#     end
#
#     module SelectField
#       def self.f_hsh(name, f_set)
#         attrs_hsh(name, SelectValue.f_set(f_set))
#       end
#     end
#
#     module SelectValue
#       def self.f_set(f_set)
#         f_set.map {|f_name| attrs_hsh(f_name)}
#       end
#     end
#
#     module Properties
#       module NumberField
#         def self.f_hsh(name)
#           attrs_hsh(name)
#         end
#       end
#
#       module TextField
#         def self.f_hsh(name)
#           attrs_hsh(name)
#         end
#       end
#     end
#   end
#   # module FieldGroup
#   #   module A
#   #     def self.set(klass, name)
#   #       [
#   #         [
#   #           :FieldSet, "#{name}-field-set",
#   #             [
#   #               [:SelectField, "#{name}-type", scope_context(klass, SelectValues)]
#   #
#   #             ]
#   #         ]
#   #       ]
#   #     end
#   #   end
#   # end
#
#   module Medium
#
#     module Painting
#       module SelectValues
#         def self.set
#           ['painting', 'oil', 'acrylic', 'mixed media']
#         end
#       end
#     end
#
#     # module Painting
#     #   module SelectValues
#     #     def self.set
#     #       ['painting', 'oil', 'acrylic', 'mixed media']
#     #     end
#     #   end
#     # end
#
#     module PaintingOnPaper
#       module SelectValues
#         def self.set
#           ['watercolor', 'pastel', 'guache', 'sumi ink']
#         end
#       end
#     end
#
#   end
# end
#
