require 'active_support/concern'

module KindContext
  extend ActiveSupport::Concern

  #compound_kinds ##############################################################
  def set_compound_keys(context)
    compound_kind_context.map{|kinds| compound_keys(context, kinds)}
  end

  def compound_kind_context
    [[:embellishing, :category], [:leafing, :remarque], [:numbered, :signed], [:animator_seal, :sports_seal]]
  end

  def compound_keys(context, keys)
    context[keys.map(&:to_s).join('_').to_sym] = true if keys.all?{|k| context[k]}
  end

  #dependent_kinds #############################################################
  def conditional_kinds
  	{Disclaimer: ['disclaimer'], Authentication: %w[dated verification], Dimension: ['dimension']}
  end

  def compound_kinds
  	{LimitedEdition: ['numbering'], Authentication: %w[certificate animator_seal sports_seal], Submedium: %w[leafing]}
  end
  ##############################################################################

  def admin_description_keys(context, key_group, sub_key=:order)
    set_media_and_end_keys_for_punct(context, key_group)
    admin_tb_keys.map(&:to_sym).map{|tag_key| context[tag_key][sub_key] = ordered_description_keys(context, tag_key)}
    update_taglines_keys(context, key_group[:skip_hsh], sub_key)
  end

  def set_media_and_end_keys_for_punct(context, key_group)
  	admin_tb_keys.map(&:to_sym).each do |tag_key|
  		context[tag_key].merge!(config_punct_keys(context[:proof_edition], :media, key_group[tag_key][:media], key_group[tag_key][:media].index('material'), 'numbering'))
  		context[tag_key].merge!(config_punct_keys((tag_key==:body && context[:numbered]), :end_key, key_group[tag_key][:end_key], 1, 'numbering'))
  	end
  end

  def update_taglines_keys(context, skip_hsh, sub_key, tb_key=:tagline)
    tb_keys[1..2].map(&:to_sym).map {|tag_key| context[tag_key] = context[tb_key]}
    remove_giclee_and_paper(context, skip_hsh[tb_key.to_s])
  end

  def filter_order(description_keys, skip_keys)
    description_keys.select{|k| !skip_keys.include?(k)}
  end

  def ordered_description_keys(context, tag_key)
    reorder_methods.each_with_object(sorted_description_keys(context[tag_key][:order])){|meths, ordered_keys| detect_and_reorder(meths, context, ordered_keys)}
  end

  def sorted_description_keys(order_hsh)
  	order_hsh.sort_by{|k,v| v}.to_h.keys
  end

  #remove ######################################################################
  def remove_giclee_and_paper(context, remove)
    [{:giclee=> 'medium'}, {:paper=> 'material'}].map {|hsh| hsh.each {|key, kind| remove << remove_kind(context, key, kind) if context[key]}}
  end

  def remove_kind(context, key, kind)
    kind if public_send("remove_#{key.to_s}?", context)
  end

  def remove_paper?(context)
    [:category, :embellishing, :leafing, :remarque, :signature].any?{|k| context[k]}
  end

  def remove_giclee?(context)
    context[:proof_edition] || context[:numbered] && context[:embellishing] || !context[:paper]
  end

  #reorder #####################################################################
  def reorder_methods
  	[[:insert_numbering_after_medium_for_proof_edition, :insert_embellishing_before_medium_if_original],[:insert_signature_last, :reorder_signature_for_proof_edition_if_no_certificate, :reorder_signature_for_proof_edition_if_no_certificate, :insert_signature_before_medium_if_no_category_or_certificate]]
  end

  def detect_and_reorder(meths, context, ordered_keys)
  	if meth = meths.detect{|meth| public_send(meth, context)}
  		reorder_keys({keys: ordered_keys}.merge!(public_send(meth, context)))
  	end
  end

  def insert_numbering_after_medium_for_proof_edition(context)
  	{k: 'numbering', ref: 'medium', i: 1} if context[:proof_edition]
  end

  def insert_embellishing_before_medium_if_original(context)
  	{k: 'embellishing', ref: 'medium'} if !context[:numbering] && context[:embellishing_category]
  end

  def insert_signature_last(context)
  	{k: 'signature', i: -1} if context[:unsigned]
  end

  def reorder_signature_for_proof_edition_if_no_certificate(context)
  	{k: 'signature', ref: (!context[:embellishing] ? 'category' : 'embellishing')} if context[:signed] && context[:proof_edition] && !context[:certificate]
  end

  def insert_signature_before_medium_if_no_category_or_certificate(context)
  	{k: 'signature', ref: 'medium'} if context[:signed] && [:certificate, :category, :numbered].none?{|k| context.include?(k)}
  end

  #punct #######################################################################
  def config_punct_keys(insert_numbering_key, sub_key, keys, idx, ref_key)
    {sub_key=> insert_numbering_key ? keys.insert(idx, ref_key) : keys}
  end

  def punct_hsh(context, description_keys, tag_key, hsh={})
    hsh[:media] = filter_media(context[tag_key][:media], description_keys)[-1]
    hsh[:end_key] = end_punct_key(context, description_keys, tag_key)
    hsh[:title_key] = description_keys[description_keys.index('title')+1] if tag_key==:body
    hsh
  end

  def filter_media(media_keys, description_keys)
    media_keys.select{|k| description_keys.include?(k)}
  end

  def end_punct_key(context, description_keys, tag_key, sub_key=:end_key)
    tag_key==:body ? context[tag_key][sub_key][-1] : description_keys[context[tag_key][sub_key].detect{|k| context[k]} ? -2 : -1]
  end

  def tagline_punct(tagline_hsh, media_key, end_key, punct=',')
    tagline_hsh[media_key] = tagline_hsh[media_key]+punct if media_key != end_key && tagline_hsh[media_key][-1] != punct
    tagline_hsh
  end

  def body_punct(body_hsh, media_key, end_key, title_key)
    join_title(body_hsh, title_key)
    body_hsh[end_key] = body_hsh[end_key]+'.' if body_hsh[end_key]
    body_hsh[media_key] = body_hsh[media_key]+(body_hsh[end_key] ? ',' : '.')
    body_hsh
  end

  def join_title(body,k)
    body[k] = ['is', Item.indefinite_article(body[k]), body[k]].join(' ')
  end

  def invoice_tagline_punct(tagline_hsh, media_key, end_key)
    tagline_punct(tagline_hsh, media_key, end_key)
  end

  def search_tagline_punct(tagline_hsh, media_key, end_key)
    tagline_punct(tagline_hsh, media_key, end_key)
  end

  def key_group
    {
      tagline: {
        order: %w[artist title mounting embellishing category medium sculpture_type material dimension leafing remarque numbering signature signer signer_tag certificate disclaimer],
        media: %w[category medium sculpture_type material leafing remarque dimension],
        end_key: [:danger, :unsigned],
        category: [['Limited Edition']], medium: [['Giclee'], ['Hand Pulled'], ['Mixed Media']], material: [['Gallery Wrapped'], ['Rice'], ['Paper']], mounting: [['Framed']], signature: [['Unsigned'], ['Plate Signed', 'Signed'], ['Signed'], ['Signature', 'Signed'], ['Signer'], ['SignerTag']], disclaimer: [['Disclaimer', 'Danger']]
      },
      body: {
        order: %w[title text_after_title embellishing category medium sculpture_type material leafing remarque artist dated numbering signature signer signer_tag verification text_before_coa mounting animator_seal sports_seal certificate dimension disclaimer],
        media: %w[text_after_title category numbering medium sculpture_type material leafing remarque artist],
        end_key: %w[dated signature]
      },
      skip_hsh: {'tagline'=> [], 'invoice_tagline'=> %w[mounting disclaimer], 'search_tagline'=> %w[artist title mounting dimension disclaimer], 'body'=>[]}
    }
  end
end

##############################################################################
# def dependent_kinds_hsh(keys)
# 	dependent_kinds.each_with_object({}) {|(klass, kinds), h| h[klass] = kinds.reject{|k| keys.exclude?(k)}}.reject{|klass, kinds| kinds.empty?}
# end
#
# def dependent_kinds
#   {LimitedEdition: ['numbering'], Disclaimer: ['disclaimer'], Authentication: %w[certificate dated verification animator_seal sports_seal signature], Submedium: %w[leafing remarque]}
# end

# def signature_params(context, store, v, k, tag_key)
#   v = gartner_blade_signature(v, tag_key) if context[:gartner_blade] && !context[:unsigned]
#   Item.case_merge(store, v, k, tag_key)
# end
#
# def gartner_blade_signature(v, tag_key)
#   v = (tag_key == 'tagline' ? "#{v} by GartnerBlade Glass." : "This piece is hand signed by GartnerBlade Glass.")
# end
