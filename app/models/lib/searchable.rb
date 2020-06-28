class Searchable

  # def self.product_type
  #   if params[:items]
  #     params[:items][:search][:type]
  #   elsif @product && action_name == 'show'
  #     @product.type
  #   elsif !@product && action_name == 'show'
  #     default_product_type
  #   end
  # end
  #
  # def default_product_type
  #   Product.ordered_types.first
  # end

  # def self.format_selected_select_value(v)
  #   v.present? ? v : 'all'
  # end

  def self.to_class(type)
    type.constantize
  end

  class Search < Searchable
    def self.search_params
      params["items"]["search"].to_a
    end
  end

  class Show < Searchable
    def self.hello
      @product.type if @product
    end

    def self.products(product_type)
      args = {tag_params: search_params(product_type), default_set: :product_group}.compact
      to_class(product_type).tags_search(args)
    end

    def self.search_params(product_type)
      to_class(product_type).tag_search_field_group(search_keys(product_type), [@product]) if @product
    end

    def self.search_keys(product_type)
      to_class(product_type).valid_search_keys(@products)
    end

    def self.search_inputs(product_type)
      if @product
        search_params(product_type)
      else
        to_class(product_type).tag_search_field_group(search_keys(product_type), @products)
      end
    end

    def self.selected_search_inputs(product_type)
      if @product
        search_inputs(product_type)
      else
        search_inputs(product_type).keys.map{|k| [k, 'all']}
      end
    end

  end

  class Update < Searchable
  end

end
