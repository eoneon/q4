require 'active_support/concern'

module HattrSearch
  extend ActiveSupport::Concern

  class_methods do

    # PART I: ##################################################################
    def search_params(scope: nil, search_params: nil, hstore:)
      search_params ? search_params : scope.public_send(hstore).select{|k,v| search_keys.include?(k)}
    end

    # PART II: #################################################################
    def hattr_search(scope:, search_params:, restrict:, hstore:)
      results = hattr_query_case(scope: scope, search_params: search_params, restrict: restrict, hstore: hstore)
      order_search(results, %w[category_search medium_search], hstore)
    end

    # A: hattr_query_case ######################################################
    def hattr_query_case(scope:, search_params:, restrict:, hstore:)
      if search_params.values.reject{|v| v.blank?}.empty?
        index_query(scope, search_params.keys, restrict, hstore)
      else
        search_query(scope, search_params.reject{|k,v| v.blank?}, hstore)
      end
    end

    # A(1): hattr_query_case dependencies
    def index_query(set, keys, restrict, hstore)
      restrict ? set.where("#{hstore}?& ARRAY[:keys]", keys: keys) : set.all
    end

    # A(2): hattr_query_case dependencies
    def search_query(set, hattrs, hstore)
      set.where(hattrs.to_a.map{|kv| query_params(kv[0], kv[1], hstore)}.join(" AND "))
    end

    # A(2)(i): search_query dependencies
    def query_params(k,v, hstore)
      "#{hstore} -> \'#{k}\' = \'#{v}\'"
    end

    # B: order_search & dependencies ###########################################
    def order_search(search_results, sort_keys, hstore)
      search_results.sort_by{|i| sort_keys.map{|k| sort_value(i.public_send(hstore)[k])}} if sort_keys
    end

    def sort_value(val)
      is_numeric?(val) ? val.to_i : val
    end

    def is_numeric?(s)
      !!Float(s) rescue false
    end
    ############################################################################
    ############################################################################

    # PART III: #################################################################
    def search_inputs(search_params, results, hstore)
      a = search_params.each_with_object([]) do |(k,v),a|
        a.append(search_input(k, v, results, hstore))
      end
    end

    def search_input(k, v, results, hstore)
      {'input_name'=> k, 'selected'=> v, 'opts'=> results.map{|obj| obj.public_send(hstore)[k]}.uniq.compact}
    end

  end
end

# search_params dependencies
# def search_value(scope, search_params, hstore, k)
#   if search_params
#     search_params[k]
#   elsif scope
#     scope.public_send(hstore)[k]
#   end
# end

# def search_params(scope: nil, search_params: nil, hstore:)
#   search_keys.map{|k| [k, search_value(scope, search_params, hstore, k)]}.to_h
# end

############################################################################
# PART I, II, II: method groups from perspective of calling method, e.g., Product
# A, B, C: subsections of above method groups
############################################################################

# def query_order(keys, hstore)
#   keys.map{|k| "#{hstore} -> \'#{k}\'"}.join(', ')
# end





# hattr_search_query #########################################################
# def hattr_search(scope:, hattrs:, hstore:)
#   {'hattrs' => hattrs, 'results' => hattr_query_case(scope: scope, hattrs: hattrs, hstore: hstore)}
# end

# def hattr_query_case(scope:, hattrs:, hstore:)
#   if hattrs.values.compact.empty?
#     index_query(scope, hattrs.keys, hstore)
#   else
#     search_query(scope, hattrs.reject{|k,v| v.blank?}, hstore)
#   end
# end

# def hattr_group(set, hattrs, hstore, input_group)
#   return if !hstore
#   hattr_query_case(set, hattrs.reject{|k,v| v.blank?}, hstore, input_group)
#   input_group.merge!({'hattrs' => search_options(input_group['opt_set'], hattrs, hstore)})
# end
#
# def hattr_query_case(set, hattrs, hstore, input_group)
#   opt_set = hattr_search_query(set, hattrs, hstore)
#   input_group.merge!({'opt_set'=> opt_set, 'search_results'=> hattr_results(hattrs, opt_set, input_group['search_results'])})
# end

# def hattr_results(hattrs, opt_set, search_results)
#   hattrs.empty? ? search_results : opt_set
# end
