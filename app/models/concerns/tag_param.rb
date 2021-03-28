require 'active_support/concern'

module TagParam
  extend ActiveSupport::Concern

  def input_params
    h = self.tags.each_with_object({}) do |(tag_key, tag_val), h|
      if valid_tag_assoc?(tag_key)
        k, t, f_name = tag_assoc_keys(tag_key)
        param_merge(params: h, dig_set: dig_set(k: f_name, v: input_val(t, tag_val), dig_keys: [k,t]))
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
