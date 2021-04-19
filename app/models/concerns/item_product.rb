require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern

  def grouped_inputs
    product ? product.input_set(product.g_hsh, input_params).group_by{|h| h[:k]} : {}
  end

  def input_params
    h = self.tags.each_with_object({}) do |(tag_key, tag_val), h|
      if valid_tag_assoc?(tag_key)
        k, t, f_name = tag_assoc_keys(tag_key)
        Item.param_merge(params: h, dig_set: Item.dig_set(k: f_name, v: input_val(t, tag_val), dig_keys: [k,t]))
      end
    end
  end

  def input_val(t, tag_val)
    tag_attr?(t) ? tag_val : detect_input_val(t, tag_val.to_i)
  end

  def detect_input_val(t, id)
    fieldables.detect{|f| attr_match?(f, t, id)}
  end

  def attr_match?(f, t, id)
    f.id == id && f.type.underscore == t
  end

  def tag_assoc_keys(tag_key)
    tag_key.split('::')
  end

  def valid_tag_assoc?(tag_key)
    tag_key.index('::')
  end
end
