class FlatArt
  extend Context
  extend ProductKind

  def self.cascade_build(store)
    p_group = build_product_group(store)
    puts "p_group: #{p_group}"
  end

  ##############################################################################

  class Painting < FlatArt
    def self.assocs
      {Category: HasOne::Category::StandardOriginal}
    end

    class StandardPainting < Painting
      def self.assocs
        {Medium: HasOne::Medium::StandardPainting,  Material: HasOne::Material::Standard}
      end

    end

    class PaintingOnPaper < Painting
      def self.assocs
        {Medium: HasOne::Medium::PaintingOnPaper, Material: HasOne::Material::Paper}
      end
    end

  end

  ####################################################

  module HasOne
    module Medium
      module StandardPainting
        def self.assocs
          {SelectField: [:OilPainting, :AcylicPainting, :MixedMediaPainting, :UnknownPainting]}
        end
      end

      module PaintingOnPaper
        def self.assocs
          {SelectField: [:WatercolorPainting, :PastelPainting, :GuachePainting]}
        end
      end
    end

    module Category
      module StandardOriginal
        def self.assocs
          {RadioButton: [:StandardOriginal]}
        end
      end
    end

    module Material
      module Standard
        def self.assocs
          {SelectField: [:StandardCanvas, :WrappedCanvas, :StandardPaper, :StandardBoard, :Wood, :WoodBox, :Acrylic, :StandardMetal, :MetalBox]}
        end
      end

      module Paper
        def self.assocs
          {SelectField: [:StandardPaper]}
        end
      end

      module PhotoPaper
        def self.assocs
          {SelectField: [:PhotoPaper]}
        end
      end

      module AnimationPaper
        def self.assocs
          {SelectField: [:AnimationPaper]}
        end
      end

      module Canvas
        def self.assocs
          {SelectField: [:StandardCanvas]}
        end
      end

      module WrappedCanvas
        def self.assocs
          {SelectField: [:WrappedCanvas]}
        end
      end
    end
  end

end #end ProductKind

# def self.assoc_set
#   [:category, :medium, :submedia, :material, :numbering, :authentication, :disclaimer]
# end
#
# def self.category
# end
#
# def self.material
# end
#
# def self.medium
# end

# def self.authentication
# end
#
# def self.disclaimer
# end

# def self.has_many_set
#   [[:Category, :RadioButton, :StandardOriginal], [:Medium, :SelectField, :StandardPainting]]
# end


  # def self.product_set(p_set, f_group)
  #   #p_set.product(f_group.values)
  # end
  #
  # def self.product_group
  #   a_group = assemble_assocs.each_with_object({HasAll:[]}) do |(kind, assoc_hsh), a_group|
  #     assoc_hsh.each do |assoc_type, f_hsh|
  #       f_hsh.each do |f_type, f_names|
  #         arrange_has_one_and_has_all(kind, assoc_type, f_type, f_names, a_group)
  #       end
  #     end
  #   end
  # end
  #
  # def self.assemble_assocs
  #   p_group = class_tree(0,2).each_with_object({}) do |klass, p_group|
  #     next unless klass.method_exists?(:assocs)
  #     klass.assocs.each do |kind, mod|
  #       assoc_group(kind, mod.to_s.split('::')[1].to_sym, mod.assocs, p_group)
  #     end
  #   end
  # end
  #
  # def self.arrange_has_one_and_has_all(kind, assoc_type, f_type, f_names, a_group)
  #   if f_names.one?
  #     a_group[:HasAll].append([kind, f_type, f_names[0]])
  #   else
  #     merge_assoc(Item.dig_set(k: kind, v: build_opts(f_names, kind, f_type), dig_keys: [assoc_type]), a_group)
  #   end
  # end
  #
  # def self.assoc_group(kind, assoc_type, mod_hsh, p_group)
  #   p_group = mod_hsh.each_with_object(p_group) do |(f_type, f_names), p_group|
  #     if p_group.dig(kind, assoc_type, f_type)
  #       p_group.dig(kind, assoc_type, f_type) + f_names
  #     else
  #       merge_assoc(Item.dig_set(k: f_type, v: f_names, dig_keys: [kind, assoc_type]), p_group)
  #     end
  #   end
  # end
