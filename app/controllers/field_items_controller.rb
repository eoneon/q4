class FieldItemsController < ApplicationController
  def create
    @field_item = FieldItem.new(field_item_params)
    @field_item.save

    respond_to do |format|
      format.js
    end
  end

  def update
    @field_item = FieldItem.find(params[:id])
    @field_item.assign_attributes(field_item_params)
    @field_item.save

    unless target_params.empty?
      target_params.each do |target_hsh|
        assoc = target_hsh.keys.first
        @field_item.scoped_target_collection(assoc) << str_to_class(assoc).update_targets(target_hsh[assoc])
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @field_item = FieldItem.find(params[:id])

    if @field_item.destroy
      respond_to do |format|
        format.js
      end
    end
  end

  private

  def field_item_params
    params.require(:field_item).permit(:type, :field_name, :id)
  end

  def target_params
    set=[]
    assoc_params.map {|k| h={k => request.params[:field_item][k]}}.each do |h|
      hsh={h.keys.first => h[h.keys.first].delete_if {|k,v| v.blank?}}
      set << hsh unless hsh[h.keys.first].empty?
    end
    set
  end

  def assoc_params
    @field_item.to_class.assoc_names.map{|assoc| assoc.to_sym}
  end
end
