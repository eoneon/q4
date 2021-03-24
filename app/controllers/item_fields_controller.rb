class ItemFieldsController < ApplicationController
  def update
    @item = Item.find(params[:id])
    @tags, @item_groups, @input_params = hsh_init(@item.tags), @item.item_groups, @item.input_params
    update_field
    @item.tags = @tags

    @item.save

    respond_to do |format|
      format.js
    end
  end

  private

  def item_params
    params.require(:item_fields).permit!
    #params.require(:item).permit(:product)
  end
  ##############################################################################
  def update_field
    params[:item].each do |k, field_groups|
      field_groups.each do |t, fields|
        fields.each do |f_name, f_val|
          item_val = get_selected(k,t_type,f_name, input_params) #@input_params.dig(k, t, f_name)
          param_val = param_val(t, f_val)
          update_field_case(t, f_name, param_val, item_val, update_case(param_val, item_val(t, item_val)))
        end
      end
    end
  end

  def update_field_case(t, f_name, param_val, item_val, context)
    case #update_case(param_val, item_val)
      when context == :add; add_param(t, f_name, new_val(t, param_val))
      when context == :remove; remove_param(t, f_name, item_val)
      when context == :replace; replace_param(t, f_name, new_val(t, param_val), item_val)
    end
  end

  def remove_field_set_fields(param_args)
    param_args.each do |f_hsh|
      if f_val = @input_params.dig(f_hsh[:k], f_hsh[:t_type], f_hsh[:f_name])
        remove_param(f_type, f_name, f_val)
      end
    end
  end

  ##############################################################################
  def update_case(param_val, item_val)
    case
      when skip?(param_val, item_val); :skip
      when remove?(param_val, item_val); :remove
      when add?(param_val, item_val); :add
      when replace?(param_val, item_val); :replace
    end
  end

  def param_val(t, param_val)
    present_field_attr?(t, param_val) ? param_val.to_i : param_val
  end

  def item_val(t, item_val)
    present_field_attr?(t, item_val) ? item_val.id : item_val
  end

  def new_val(t, param_val)
    present_field_attr?(t, param_val) ? find_target(t, param_val) : param_val
  end

  ##############################################################################

  def skip?(p_val, i_val)
    p_val.blank? && i_val.blank? || p_val == i_val
  end

  def remove?(p_val, i_val)
    p_val.blank? && !i_val.blank?
  end

  def add?(p_val, i_val)
    !p_val.blank? && i_val.blank?
  end

  def replace?(p_val, i_val)
    !p_val.blank? && !i_val.blank?
  end

  def get_selected(k,t_type,f_name, input_params)
    if t_type == "tags"
      input_params.dig(t_type, f_name)
    else
      input_params.dig(k,t_type,f_name)
    end
  end

end
