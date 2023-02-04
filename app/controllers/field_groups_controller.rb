class FieldGroupsController < ApplicationController
  def index
    #@field_items = Product.grouped_fields
    @field_items = Product.sorted_fields.group_by(&:kind)
  end

  # def new
  #   @parent = FieldItem.new.find_target(params[:parent_type], params[:parent_id])
  #   @field_item = @parent.to_class(params[:type]).new
  # end
end
