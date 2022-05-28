require 'active_support/concern'

module BatchCreate
  extend ActiveSupport::Concern



  ##############################################################################
  # def batch_create_skus(skus, sku_params, artist, product)
  # 	i = model_sku(skus[0], sku_params, artist, product)
  # 	batch_loop_create_skus(skus[1..-1], sku_params, artist, product, i.fieldables, i.tags, i.csv_tags) if skus[1..-1].any?
  # end

  # def model_sku(sku, sku_params, artist, product)
  # 	i = sku_build(sku, sku_params, artist, product)
  # 	return i if !product
  # 	i.tags = i.add_default_product_fields(product.unpacked_fields)
  # 	i.csv_tags = i.form_and_data[-1]
  # 	i.save
  # 	i
  # end
  #
  # def sku_build(sku, sku_params, artist, product)
  # 	sku_params[:sku] = sku
  # 	i = Item.create(sku_params)
  # 	i.add_obj(artist) if artist
  # 	i.add_obj(product) if product
  # 	i
  # end

  # def batch_loop_create_skus(skus, sku_params, artist, product, fields, tags, csv_tags)
  # 	skus.each do |sku|
  # 		i = sku_build(sku, sku_params, artist, product)
  # 		fields.map{|f| i.assoc_unless_included(f)} if fields.any?
  # 		i.tags = tags
  # 		i.csv_tags = csv_tags
  # 		i.save
  # 	end
  # end


  ##############################################################################
  # def batch_create_skus(skus, sku_params, artist, product)
  #   skus.each do |sku|
  #     sku_params[:sku] = sku
  #     i = Item.create(sku_params)
  #     i.add_obj(artist) if artist
  #     i.add_sku(product, sku) if product
  #   end
  # end

  # def add_sku(product, sku)
  #   add_obj(product)
  #   #self.tags = hsh_init(self.tags)
  #   tags = add_default_product_fields(product.unpacked_fields)
  #   self.tags = tags
  #   #rows, attrs = input_group
  #   rows, attrs = form_and_data
  #   update_csv_tags(attrs)
  # end

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

  ##############################################################################

  def batch_loop_create_skus(skus, sku_params)
  	skus.each do |sku|
  		i = Item.new_sku(sku, sku_params, artist)
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

  def add_model_sku_product(product)
  	add_product(product)
  	self.csv_tags = form_and_data[-1]
  	self.save
  end

  class_methods do

    def batch_create_skus(skus, sku_params, artist, product)
    	i = model_sku(skus[0], sku_params, artist, product)
    	i.batch_loop_create_skus(skus[1..-1], sku_params) if skus[1..-1].any?
    end

    def model_sku(sku, sku_params, artist, product)
    	i = new_sku(sku, sku_params, artist)
    	i.add_model_sku_product(product) if product
    	i
    end

    def new_sku(sku, sku_params, artist)
    	sku_params[:sku] = sku
    	i = create(sku_params)
    	i.add_obj(artist) if artist
    	i
    end

  end
end
