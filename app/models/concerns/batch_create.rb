require 'active_support/concern'

module BatchCreate
  extend ActiveSupport::Concern

  def batch_dup_skus(skus, sku_params, artist)
  	fields_and_tags = {:fields=> fieldables, :tags=> tags.reject{|k,v| black_list.include?(k.split('::').last)}}
  	i = Item.model_dup_sku(skus[0], sku_params, fields_and_tags, artist, product)
    i.batch_loop_create_skus(skus[1..-1], sku_params) if skus[1..-1].any?
  end

  def batch_dup_items(skus, item_params, artist, params_hsh, dig_group)
    i = dup_item(skus, item_params, artist, tags.reject{|k,v| black_list.include?(k.split('::').last)}, params_hsh, dig_group)
    i.batch_loop_create_skus(skus[1..-1], item_params) if skus[1..-1].any?
  end

  def get_hattr_form_rows(rows, dig_keys_for_dup_form)
    rows.any? ? dig_keys_for_dup_form.each_with_object({}) {|dig_keys, new_rows| filter_row(*dig_keys, rows, new_rows)} : {}
  end

  def filter_row(k, t, rows, new_rows)
    rows[k].map{|form_lev, field_set| Item.case_merge(new_rows, field_set.select{|f_hsh| f_hsh[:t_type]==t}, k, form_lev)}
  end

  def black_list
    %w[severity damage edition edition_size]
  end

  ##############################################################################
  def dup_item(skus, item_params, artist, tag_hsh, params_hsh, dig_group)
  	Item.model_dup_sku(skus[0], item_params, {:fields=> fieldables, :tags=> update_tag_hsh(params_hsh, tag_hsh, dig_group)}, artist, product)
  end

  def update_tag_hsh(params_hsh, tag_hsh, dig_group)
  	return {} if !tag_hsh
  	dig_group.each_with_object(tag_hsh) {|dig_keys, tag_hsh| update_dup_tags(tag_hsh, params_hsh.dig(*dig_keys), *dig_keys)}
  end

  def update_dup_tags(tag_hsh, hattrs, k, t)
  	hattrs.each_with_object(tag_hsh) do |(f_name,v), tag_hsh|
      tag_key = [k, t, f_name].join('::')
  		v.present? ? tag_hsh[tag_key] = v : tag_hsh.delete(tag_key)
  	end
  end

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
