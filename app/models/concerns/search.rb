require 'active_support/concern'

module Search
  extend ActiveSupport::Concern

  class_methods do
    # Item.search
    # def search(scope:nil, joins:nil, hstore:nil, attrs:{}, hattrs:{}, input_group:{}, sort_keys:[])
    #   results_or_self = scope_group(scope, joins, input_group)
    #   results_or_self = attr_group(results_or_self, attrs, input_group)
    #   results = hstore_group(results_or_self, hattrs, hstore, input_group)
    #   order_search(uniq_hattrs(results), sort_keys, hstore)
    # end

    # join_search (I) ##########################################################
    def scope_group(scope, joins, input_group)
      input_group['scope'] = scope.try(:id)
      results = scope_search(scope, joins)
      results.blank? ? self : results
    end

    def scope_search(scope, joins)
      joins && scope ? scope_query(scope, joins) : []
    end

    def scope_query(scope, joins)
      self.joins(joins).where(joins => {target_type: scope.class.base_class.name, target_id: scope.id})
    end

    # attr_search (II) #########################################################
    def attr_group(results_or_self, attrs, input_group)
      input_group['attrs'] = attrs
      results = attr_search(results_or_self, attrs.reject{|k,v| v.blank?})
      results.blank? ? results_or_self : results
    end

    def attr_search(results_or_self, attrs)
      attrs.any? ? results_or_self.where(attrs) : []
    end

    # hattr_search (III) #######################################################
    def hstore_group(results_or_self, hattrs, hstore, input_group)
      input_group['hattrs'] = hattrs
      hattr_search(results_or_self, hattrs.reject{|k,v| v.blank?}, hstore, nil)
    end

    def hattr_search(results_or_self, hattrs, hstore, default_set=:all)
      results = hstore_search(results_or_self, hattrs, hstore, default_set)
      order_search(results, search_keys, hstore)
    end

    def hstore_search(results_or_self, hattrs, hstore, default_set)
      hstore && hattrs.any? ? hstore_query(results_or_self, hattrs, hstore) : default_results(results_or_self, default_set)
    end

    def default_results(results_or_self, default_set)
      default_set==:all ? results_or_self.all : []
    end

    # filtering search: uniq/order ############################################# uniq_search uniq_hattr_search
    def uniq_hattrs(results, keys, hstore, running_list=[])
      results.each_with_object([]){|i,uniq_set| assign_unique(i, keys, hstore, running_list, uniq_set)}
    end

    def assign_unique(i, keys, hstore, running_list, uniq_set)
      comparison_hsh = filtered_hsh(h: i.public_send(hstore), keys: keys)
      return if running_list.include?(comparison_hsh)
      running_list << comparison_hsh
      uniq_set << i
    end

    def order_search(results, sort_keys, hstore)
      results.sort_by{|i| sort_keys.map{|k| sort_value(i.public_send(hstore)[k])}} if sort_keys
    end

    def sort_value(val)
      is_numeric?(val) ? val.to_i : val
    end

    def is_numeric?(s)
      !!Float(s) rescue false
    end

    # hstore query/params methods ##############################################
    def index_query(results_or_self, keys, hstore)
      results_or_self.where("#{hstore}?& ARRAY[:keys]", keys: keys)
    end

    def hstore_query(results_or_self, search_params, hstore)
      results_or_self.where(search_params.to_a.map{|kv| hstore_params(kv[0], kv[1], hstore)}.join(" AND "))
    end

    def hstore_params(k,v, hstore)
      "#{hstore} -> \'#{k}\' = \'#{v}\'"
    end

    def hattr_params(scope, hattrs, hstore)
      hattrs ? hattrs : build_hattr_params(scope, hstore)
    end

    def build_hattr_params(scope, hstore)
      scope ? scope_hattr_params(scope, hstore) : search_keys.each_with_object({}) {|k,h| h[k]=""}
    end

    def scope_hattr_params(scope, hstore)
      search_keys.each_with_object({}){|k,h| h[k] = scope.public_send(hstore).dig(k)}
    end

    # search_inputs ############################################################
    def search_inputs(results, hattrs, hstore)
      hattrs.each_with_object([]) do |(k,v), inputs|
        inputs.append(search_input(k, v, results, hstore))
      end
    end

    def search_input(k, v, results, hstore)
      {'input_name'=> k, 'selected'=> v, 'opts'=> results.map{|obj| obj.public_send(hstore)[k]}.uniq.compact}
    end

    def select_input_opts(opt_set, k, hstore)
      opt_set.map{|i| i.public_send(hstore)[k]}.uniq.compact.prepend('-- All --')
    end

  end
end

# h.merge!({k=>{'opts'=> select_input_opts(opt_set, k, hstore), 'selected'=>v}})

# def hstore_search(scope, hattrs, hstore)
#   results = inclusive_hstore_search(hattrs.reject{|k,v| v.blank?}, hstore)
#   order_search(results, search_keys, hstore)
# end

# def inclusive_hstore_search(hattrs, hstore)
#   hattrs.any? ? hstore_query(self, hattrs, hstore) : self.all
# end

# def exclusive_hstore_search(results_or_self, hattrs, hstore)
#   hattrs.any? && hstore ? hstore_query(results_or_self, hattrs, hstore) : []
# end

# def search(scope:nil, joins:nil, hstore:nil, attrs:{}, hattrs:{}, input_group:{})
#   set = scope_search(scope, joins, input_group)
#   set = attr_group(set, attrs.reject{|k,v| v.blank?}, input_group)
#   set = hstore_search(set, hattrs.reject{|k,v| v.blank?}, hstore, input_group)
#   set
# end

# def distinct_hstore(opt_set, running_list=[], set=[])
#   opt_set.each do |i|
#     assign_unique(i, running_list, set)
#   end
#   set
# end

# def results_or_self(results)
#   results.blank? ? self : results
# end

# def hstore_search(set, hattrs, hstore, input_group)
#   return default_search_results(set) if !hstore
#   hstore_query_case(set, hattrs, hstore, input_group)
#   input_group.merge!({'hattrs' => search_inputs(input_group['opt_set'], hattrs, hstore)})
# end
#

# def inclusive_hstore_query_case(results_or_self, hattrs, hstore, search_keys)
#   if hattrs.any? && hstore
#     search_query(results_or_self, hattrs, hstore)
#   else
#     index_query(results_or_self, search_keys, hstore)
#   end
# end

# def hstore_search_query(set, hattrs, hstore)
#   if hattrs.empty?
#     index_query(set, hattrs.keys, hstore)
#   else
#     search_query(set, hattrs, hstore)
#   end
# end

# def default_search_results(set)
#   set == self ? [] : set
# end
#
# def hstore_query_case(set, hattrs, hstore, input_group)
#   uniq_set = uniq_hattrs(hstore_search_query(set, hattrs, hstore))
#   input_group.merge!({'opt_set'=> uniq_set, 'search_results'=> uniq_set})
# end

# def hstore_query_case(set, hattrs, hstore, input_group)
#   uniq_set = uniq_hattrs(hstore_search_query(set, hattrs, hstore))
#   input_group.merge!({'opt_set'=> uniq_set, 'search_results'=> uniq_set})
# end







# def uniq_hattrs(set, keys, hstore, running_list=[])
#   set.each_with_object([]) |i,uniq_set|
#     test_hsh = filtered_hsh(h: i.public_send(hstore), keys: keys)
#     next if running_list.include?(test_hsh)
#     running_list << test_hsh
#     uniq_set << i
#   end
# end

# def hattr_search(set, search_params, hstore, input_group)
#   return default_search_results(set) if !hstore
#   #context = search_params.all?{|k,v| v.index(' All ')} ? :all : nil
#   hstore_query_case(set, search_params.reject{|k,v| v.index(' All ')}, hstore, context, input_group)
#
#   input_group.merge!({'hattrs' => search_inputs(h['opt_set'], search_params, hstore)})
# end

# hattr_search: hstore_query_case (a) #######################################
# def hstore_query_case(set, search_params, context, hstore, input_group)
#   opt_set = distinct_hstore(hstore_search_query(set, search_params, hstore))
#   search_results = context ==  :all ? opt_set : []
#   h.merge!({'opt_set'=> opt_set, 'search_results'=> search_results})
# end

# hattr_search: hstore_search_query (b) #####################################
# def hstore_search_query(set, search_params, hstore)
#   if search_params.empty?
#     index_query(set, search_params.keys, hstore)
#   else
#     search_query(set, search_params, hstore)
#   end
# end
