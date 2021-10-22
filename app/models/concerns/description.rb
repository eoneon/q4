require 'active_support/concern'

module Description
  extend ActiveSupport::Concern

  def kind_param_case(context, store, v, sub_hsh, k, tag_key)
    case k
      when 'embellishing'; embellishing_params(store, v, k, tag_key)
      when 'numbering'; numbering_params(context, store, v, sub_hsh, k, tag_key)
      when 'signature'; signature_params(context, store, v, k, tag_key)
      when 'leafing'; leafing_params(context, store, v, k, tag_key)
      when 'dated'; dated_params(context, store, v, sub_hsh, k, tag_key)
      when 'animator_seal'; animator_seal_params(context, store, v, k, tag_key)
      when 'sports_seal'; sports_seal_params(context, store, v, k, tag_key)
      #when 'certificate'; certificate_params(store, v, k, tag_key)
      when 'verification'; verification_params(context, store, v, sub_hsh, k, tag_key)
      when 'disclaimer'; disclaimer_params(context, store, v, sub_hsh, k, tag_key)
      else Item.case_merge(store, v, k, tag_key)
    end
  end

  def embellishing_params(store, v, k, tag_key)
    Item.case_merge(store, 'Embellished', k, 'abbrv') if tag_key=='tagline'
    Item.case_merge(store, v, k, tag_key)
  end

  # def certificate_params(store, v, k, tag_key)
  #   Item.case_merge(store, Item.str_edit(str: v, swap: ['Letter of Authenticity', 'LOA', 'Certificate of Authenticity', 'COA'], skip:['with']), k, 'abbrv') if tag_key=='tagline'
  #   Item.case_merge(store, v, k, tag_key)
  # end

  def animator_seal_params(context, store, v, k, tag_key)
    v = v+'.' unless context[:sports_seal]
    Item.case_merge(store, v, k, tag_key)
  end

  def sports_seal_params(context, store, v, k, tag_key)
    v = v.sub('This piece bears', 'and') if context[:animator_seal]
    Item.case_merge(store, v+'.', k, tag_key)
  end

  # numbering
  def numbering_params(context, store, v, sub_hsh, k, tag_key)
    ed_val, conj = edition_value(sub_hsh), ('and' if context[:numbered_signed])
    Item.case_merge(store, [v, ed_val, conj].compact.join(' '), k, tag_key)
  end

  def edition_value(sub_hsh)
    if sub_hsh.keys.count == 2
      sub_hsh.values.join('/')
    elsif sub_hsh.keys.include?('edition_size')
      "out of #{k_hsh['edition_size']}"
    end
  end

  # signature
  def signature_params(context, store, v, k, tag_key)
    v = gartner_blade_signature(v, tag_key) if context[:gartner_blade] && !context[:unsigned]
    Item.case_merge(store, v, k, tag_key)
  end

  def gartner_blade_signature(v, tag_key)
    v = (tag_key == 'tagline' ? "#{v} by GartnerBlade Glass." : "This piece is hand signed by GartnerBlade Glass.")
  end

  # submedia
  def leafing_params(context, store, v, k, tag_key)
    v = (context[:leafing_remarque] ? "#{v} and" : v)
    Item.case_merge(store, v, k, tag_key)
  end

  def remarque_params(context, store, v, k, tag_key)
    v = "with #{v}" if !context[:leafing]
    Item.case_merge(store, v, k, tag_key)
  end

  # dated
  def dated_params(context, store, v, sub_hsh, k, tag_key)
    return if sub_hsh.none?
    Item.case_merge(store, [v, format_date(context, "(#{sub_hsh.values[0]})")].join(' '), k, tag_key)
  end

  def format_date(context, v)
    case
      when context[:numbered_signed]; v+','
      when context[:signed] || context[:numbered]; v+' and'
      else v+'.'
    end
  end

  # verification
  def verification_params(context, store, v, sub_hsh, k, tag_key)
    return if sub_hsh.none?
    Item.case_merge(store, [v, "#{sub_hsh.values[0]}"].join(' '), k, tag_key)
  end

  # disclaimer
  def disclaimer_params(context, store, v, sub_hsh, k, tag_key)
    return if sub_hsh.none?
    v = disclaimer(v, sub_hsh.values[0]) if tag_key == 'body'
    Item.case_merge(store, v, k, tag_key)
  end

  def disclaimer(severity, damage)
    case severity
      when 'danger'; "** Please note: #{damage} **"
      when 'warning'; "Please note: #{damage}"
      when 'notation'; damage
    end
  end

  def contexts
    {
      present_keys: %w[artist embellishing category medium sculpture_type material leafing remarque date seal certificate], #
      compound_kinds: [[:embellishing, :category], [:leafing, :remarque], [:numbered, :signed], [:animator_seal, :sports_seal], [:seal, :certificate]],
      related_args: [
        {k: 'material', related: 'mounting', d_tag: 'material_dimension', end_key: 'body'},
        {k: 'mounting', related: 'dimension', d_tag: 'mounting_dimension', end_key: 'mounting_dimension'},
        {k: 'dimension', d_tag: 'material_dimension', d_tag2: 'mounting_dimension', material_dimensions: nil, mounting_dimensions: nil, material_tag: nil, mounting_tag: nil}
      ],

      gartner_blade: %w[category text_after_title sculpture_type sculpture_part signature dimension disclaimer],

      tagline: {
        keys: %w[artist title mounting embellishing category medium sculpture_type material dimension leafing remarque numbering signature animator_seal sports_seal certificate disclaimer],
        vals: [['Limited Edition'],['Giclee'],['Hand Pulled'],['Unsigned'],['Plate Signed', 'Signed'],['Signed'],['Signature', 'Signed'],['Disclaimer']], #['Gallery Wrapped'],['Paper'],
        media: %w[category medium sculpture_type material leafing remarque dimension],
        authentication: [:disclaimer, :unsigned]
      },

      abbrv:{
        keys:%w[artist title embellishing category medium sculpture_type material dimension leafing numbering signature certificate],
        set: [['Letter of Authenticity', 'LOA'], ['Certificate of Authenticity', 'COA'], ['with ', 'w/'], ['Limited Edition', 'Ltd Ed'], ['Edition', 'Ed'], ['Numbered', 'No'], ['Mixed Media', 'MM'], ['Hand Pulled', 'HP']]
      },

      body:{
        keys: %w[title text_after_title embellishing category medium sculpture_type material leafing remarque artist dated numbering signature verification text_before_coa mounting animator_seal sports_seal certificate dimension disclaimer],
        media: %w[text_after_title category numbering medium sculpture_type material leafing remarque artist],
        authentication: %w[dated numbering signature]
      }
    }
  end

end

# def untitled?(h)
#   h.dig('title', 'tagline').blank?
# end
