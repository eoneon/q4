class GartnerBlade
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.product_name
    'GartnerBlade'
  end

  def self.assocs
    {
      Category: [[:RadioButton, :GartnerBladeGlass]],
      SculptureType: end_keys(:FieldSet, :PrimitiveBowl, :PrimitiveShell, :IkebanaFlowerBowl, :SaturnOilLamp, :ArborSculpture, :OpenBowl, :OpenVase, :CoveredBowl, :CoveredVase),
      Signature: [[:SelectField, :StandardSignature]],
      Disclaimer: [[:FieldSet, :StandardDisclaimer]]
    }
  end

  # new 26 ########################################################################
  def build_gartner_blade(keys, title, context, attrs, store)
    attrs.merge!({'title'=> title})
    category(store, 'category', "\"#{title}\"", (context[:signed] ? ',' : '.'), title.downcase.index('sculpture'))
    attr_description(keys, store, attrs)
  end

  def category(store, key, title, punct, sculp)
    tb_hsh = slice_and_delete(store, key)
    store[key] = tb_hsh.each_with_object({}) {|(k, v),h| h[k] = format_category(k, v, title, punct, sculp)}
  end

  def format_category(k, v, title, punct, sculp)
    if k=='tagline'
      [title, v+punct].join(' ')
    else
      v = v.split(' ')[0..-2].join(' ') if sculp
      v = ["This", v].join(' ')
      v.sub('glass', title)
    end
  end

  def attr_description(keys, store, attrs)
    %w[tagline body].each do |k|
      key = (k=='body' ? 'description' : k)
      attrs[key] = filtered_hsh(h: store, keys: keys, dig_set: [k]).values.join(' ')
    end
  end
  ##############################################################################

  # ## gartner_blade_attrs
  # def gartner_blade_attrs(d_hsh, attrs)
  #   attrs.merge!({'title'=> attr_title(title_hsh(d_hsh))})
  #   %w[artist title].map{|k| d_hsh.delete(k)}
  # end
  #
  # def title_hsh(d_hsh, tag_key='tagline')
  #   %w[sculpture_type sculpture_part].each_with_object({}) do |k,h|
  #     if tb_hsh = slice_and_delete(d_hsh,k)
  #       k=='sculpture_type' ? h[k] = tb_hsh[tag_key].values[0] : h.merge!(tb_hsh[tag_key])
  #     end
  #   end
  # end
  #
  # def attr_title(title_hsh)
  #   %w[size color sculpture_type lid].map{|k| title_hsh.dig(k)}.compact.join(' ')
  # end
  #
  # ## gartner_blade_related_category
  # def gartner_blade_related_category(d_hsh, store, title, signed, key='category')
  #   gartner_blade_related_tagline(d_hsh, store, title, signed, key)
  #   gartner_blade_related_body(d_hsh, store, title, key)
  #   d_hsh.delete(key)
  # end
  #
  # def gartner_blade_related_tagline(d_hsh, store, title, signed, key, tag_key='tagline')
  #   Item.case_merge(store, [title, d_hsh[key][tag_key].values[0]+(signed ? ',' : '.')].join(' '), key, tag_key)
  # end
  #
  # def gartner_blade_related_body(d_hsh, store, title, key, tag_key='body')
  #   category = d_hsh[key][tag_key].values[0]
  #   category = category.split(' ')[0..-2].join(' ') if title.downcase.index('sculpture')
  #   v = ["This", category].join(' ')
  #   Item.case_merge(store, v.sub('glass', title), key, tag_key)
  # end
  #
  # def gartner_blade_description(context, store, hsh={'tagline'=>nil, 'description'=>nil})
  #   hsh['tagline'] = gb_tagline(context, store, Item.new.valid_description_keys(store, Item.new.contexts[:tagline][:keys], 'tagline'))
  #   hsh['description'] = gb_body(context, store, Item.new.valid_description_keys(store, Item.new.contexts[:body][:keys], 'body'))
  #   hsh
  # end
  #
  # def gb_tagline(context, store, keys)
  #   keys = remove_keys(keys,'artist')
  #   filtered_hsh(h: store, keys: keys, dig_set: ['tagline']).values.join(' ')
  # end
  #
  # def gb_body(context, store, keys)
  #   keys = remove_keys(keys,'artist')
  #   reorder_keys(keys: keys, k:'text_after_title', ref: 'category', i: 1)
  #   filtered_hsh(h: store, keys: keys, dig_set: ['body']).values.join(' ')
  # end
end

# def gartner_blade_hsh(d_hsh)
#   %w[sculpture_type sculpture_part].each_with_object({}) do |k,h|
#     puts "d_hsh: #{d_hsh}"
#     if tag_hsh = d_hsh.dig(k, 'tagline')
#       puts "tag_hsh: #{tag_hsh}"
#       k=='sculpture_type' ? h[k] = tag_hsh.values[0] : h.merge!(tag_hsh)
#       d_hsh.delete(k)
#     end
#   end
# end

# def gartner_blade_attr_title(title_hsh)
#   %w[size color sculpture_type lid].map{|k| title_hsh.dig(k)}.compact.join(' ')
# end
