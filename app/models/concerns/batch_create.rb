require 'active_support/concern'

module BatchCreate
  extend ActiveSupport::Concern

  def batch_dup_skus(skus, sku_params, artist)
  	fields_and_tags = {:fields=> fieldables, :tags=> tags.reject{|k,v| black_list.include?(k.split('::').last)}}
  	i = Item.model_dup_sku(skus[0], sku_params, fields_and_tags, artist, product)
    i.batch_loop_create_skus(skus[1..-1], sku_params) if skus[1..-1].any?
  end

  def black_list
    %w[severity damage mounting_width mounting_height edition edition_size]
  end

  ##############################################################################

  def batch_loop_create_skus(skus, sku_params)
  	skus.each do |sku|
  		i = Item.new_sku(sku, sku_params, artist)
      csv_tags['sku'] = sku
  		i.dup_sku_product(product, fieldables, tags, csv_tags) if product
  	end
  end

  def dup_sku_product(product, fields, tags, csv_tags)
  	add_obj(product)
  	fields.map{|f| assoc_unless_included(f)}
  	self.tags = tags
  	self.csv_tags = csv_tags
  	self.save
  end

  def dup_product(product, fields_and_tags)
  	add_obj(product)
  	assign_fields_and_tags(fields_and_tags)
  	assign_cvtags_with_rows(form_and_data, :dup)
  end

  class_methods do

    def batch_create_skus(skus, sku_params, artist, product)
    	i = model_sku(skus[0], sku_params, artist, product)
    	i.batch_loop_create_skus(skus[1..-1], sku_params) if skus[1..-1].any?
    end

    def model_sku(sku, sku_params, artist, product)
      i = new_sku(sku, sku_params, artist)
      product ? i.add_product(product, :dup) : i
    end

    def model_dup_sku(sku, sku_params, fields_and_tags, artist, product)
  		i = new_sku(sku, sku_params, artist)
  		i.dup_product(product, fields_and_tags)
    end

    def new_sku(sku, sku_params, artist)
    	sku_params[:sku] = sku
    	i = create(sku_params)
    	i.add_obj(artist) if artist
    	i
    end

  end
end
