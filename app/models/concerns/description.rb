require 'active_support/concern'

module Description
  extend ActiveSupport::Concern

  def item_fields_hsh(input_params)
    h = input_params.each_with_object({}) do |(k, field_groups), h|
      field_groups.each do |t, fields|
        if option?(t) && field_groups.one? && fields.one?
          h[k] = fields.values[0].field_name
        elsif dimension?(k) && tag_attr?(t)
          dimension_hsh(h, k, fields.reject{|i| i.blank?})
        elsif numbering?(k) && tag_attr?(t)
        end
      end
    end
  end
end
