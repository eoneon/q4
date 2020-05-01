class Menu
  include Context

  def self.pop_media
    set=[]
    ItemType::Medium.constants.each do |medium|
      #p = ItemType.new #(type: 'medium', name: 'painting', origin_type: 'ProductItem', f_set: [])
      #p_hsh = ItemType.attrs_hsh
      #ProductItem.new()
      #p_hsh = {attrs: attrs={type: medium, name: medium, origin_type: 'ProductItem'}, f_set: []}
      #p.attrs_hsh(type: slice_class(-2), name: decamelize(klass_name), origin_type: slice_class(-2), f_set: [])
      #p.attrs_hsh(type: 'medium', name: 'painting', origin_type: 'ProductItem', f_set: [])
      set << p_hsh
    end
    set
  end

  ############################################
  class ItemType
    #attr_accessor :type, :item_name, :origin_type, :f_set

    # def attrs_hsh(type:, name:, origin_type:, f_set: [])
    #   h={attrs: {type: type, item_name: name}, origin_type: origin_type, f_set: f_set}
    # end
    def self.attrs_hsh
      h={attrs: attr={type: nil, item_name: nil}, origin_type: nil, f_set: []}
    end

    class Medium < ItemType
      module Painting

      end
    end

    class Material
      module Canvas

      end

    end
  end




end
