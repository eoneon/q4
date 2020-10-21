require 'active_support/concern'

module SkuRange
  extend ActiveSupport::Concern

  class_methods do

    #sku_ranges: params[:skus].split(",")
    def skus(sku_ranges, set=[])
      sku_ranges.split(",").each do |sku_block|
        build_skus(sku_block, set)
      end
      set.flatten
    end

    def build_skus(sku_block, set)
      if sku_block.index('-')
        validate_sku_range(sku_block.split('-'), set)
      else
        validate_sku(extract_digits(sku_block), set)
      end
    end

    def validate_sku_range(sku_range, set)
      [:range_values?, :valid_sku_range_type?, :valid_range?].each do |meth|
        sku_range = public_send(meth, sku_range)
        puts "sku_range: #{sku_range}"
        return if sku_range.nil?
      end
      set << sku_range.to_a
    end

    def range_values?(sku_range)
      sku_range.map{|i| extract_digits(i)} if sku_range.none?{|i| i.blank?} && sku_range.count == 2
    end

    def validate_sku(sku, set)
      set << sku if validate_sku_type?(sku)
    end

    def validate_sku_type?(sku)
      sku if sku.length <= 3 || sku.length == 6
    end

    def valid_sku_range_type?(sku_range)
      sku_range.map{|i| i.to_i} if sku_range.all?{|i| i.length <= 3} || sku_range.all?{|i| i.length == 6}
    end

    def valid_range?(sku_range)
      (sku_range[0]..sku_range[1]) if sku_range[0] < sku_range[1]
    end

    def extract_digits(num_str)
      num_str.gsub(/\D/, '')
    end

  end
end
