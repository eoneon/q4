require 'active_support/concern'

module Search
  extend ActiveSupport::Concern

  class_methods do
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

# def results_or_self(results)
#   results.blank? ? self : results
# end

# def default_search_results(set)
#   set == self ? [] : set
# end

# def uniq_hattrs(set, keys, hstore, running_list=[])
#   set.each_with_object([]) |i,uniq_set|
#     test_hsh = filtered_hsh(h: i.public_send(hstore), keys: keys)
#     next if running_list.include?(test_hsh)
#     running_list << test_hsh
#     uniq_set << i
#   end
# end
