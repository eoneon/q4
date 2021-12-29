require 'active_support/concern'

module BatchCreate
  extend ActiveSupport::Concern

  def batch_create_skus(skus, sku_params, artist, product, product_args)
    skus.each do |sku|
      sku_params[:sku] = sku
      i = Item.create(sku_params)
      i.add_obj(artist) if artist
      i.add_sku(product, product_args, sku) if product
    end
  end

  def add_sku(product, product_args, sku)
    add_obj(product)
    self.tags = hsh_init(self.tags)
    add_default_fields(product_args)
    rows, attrs = input_group
    update_csv_tags(attrs)
  end

  ##############################################################################

  def batch_dup_skus(skus, sku_params, artist)
    skus.each do |sku|
      sku_params[:sku] = sku
      i = Item.create(sku_params)
      i.add_obj(artist) if artist
      i.add_obj(product)
      i.dup_product_assocs(product, fieldables, tags.reject{|k,v| black_list.include?(k.split('::').last)})
    end
  end

  def dup_product_assocs(product, fields, tag_assocs)
    self.tags = tag_assocs
    fields.map{|f| assoc_unless_included(f)}
    rows, attrs = input_group
    update_csv_tags(attrs)
  end

  def black_list
    %w[severity damage mounting_width mounting_height edition edition_size]
  end
end
