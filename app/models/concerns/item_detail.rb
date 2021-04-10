require 'active_support/concern'

module ItemDetail
  extend ActiveSupport::Concern

  def item_details(store={})
    return if !product
    store.merge!({'product'=> product.tags})
    title_params(tagline_title, body_title, store)
    item_attr_params(store)
    artist_params(store)
  end

  def title_params(tagline_title, body_title, store)
    export_headers.each do |k|
      v = k == 'body' ? body_title : tagline_title
      param_merge(params: store, dig_set: dig_set(k: 'title', v: v, dig_keys: ['item', k]))
    end
    store
  end

  def tagline_title
    self.title.blank? ? 'Untitled' : "\"#{self.title}\""
  end

  def body_title
    self.title.blank? ? 'This' : tagline_title
  end

  def item_attr_params(store)
    %w[sku retail qty].each do |k|
      param_merge(params: store, dig_set: dig_set(k: k, v: self.public_send(k), dig_keys: %w[item export_tag]))
    end
    store
  end

  def artist_params(store)
    return if !artist
    artist.artist_params.each do |k,v|
      param_merge(params: store, dig_set: dig_set(k: k, v: v, dig_keys: ['artist']))
    end
    store
  end

  def export_headers
    %w[tagline search_line body export_tag]
  end
end
