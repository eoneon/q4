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

  # build_gartner_blade ########################################################
  def build_gartner_blade(keys, title, context, attrs, store)
    attrs.merge!({'title'=> title})
    category(store, 'category', "\"#{title}\"", (context[:signed] ? ',' : '.'), title.downcase.index('sculpture'))
    attr_description(keys, store, attrs)
    attrs['invoice_tagline'] = [attrs['tagline'], store.dig('dimension', 'invoice_tagline')].compact.join(' ')
  end

  def category(store, key, title, punct, sculp)
    tb_hsh = slice_and_delete(store, key)
    store[key] = tb_hsh.each_with_object({}) {|(k, v),h| h[k] = format_category(k, v, title, punct, sculp)}
  end

  def format_category(k, v, title, punct, sculp)
    if k=='tagline'
      punct=='.' ? "#{title} #{v} by GartnerBlade Glass." : [title, v+punct].join(' ')
    else
      v = v.split(' ')[0..-2].join(' ') if sculp
      v = ["This", v].join(' ')
      v.sub('glass', title)
    end
  end

  def attr_description(keys, store, attrs)
    %w[tagline body].each do |k|
      attrs[(k=='body' ? 'description' : k)] = filtered_hsh(h: store, keys: keys, dig_set: [k]).values.join(' ')
    end
  end

end
