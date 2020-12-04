require 'active_support/concern'

module Search
  extend ActiveSupport::Concern

  class_methods do

    def search(scope: nil, joins: nil, hstore:nil, attrs:{}, hattrs:{}, input_group:{})
      set = scope_group(scope, joins, input_group)
      set = attr_group(set, attrs.reject{|k,v| v.blank?}, input_group)
      set = hattr_group(set, hattrs.reject{|k,v| v.blank?}, hattrs, input_group)
      set
    end

    # join_search (I) ##########################################################
    def scope_group(scope, joins, input_group)
      input_group.merge!({'scope' => scope.try(:id)})
      build_scope_group(scope, joins)
    end

    def build_scope_group(scope, joins)
      joins && scope ? scope_query(scope, joins) : self
    end

    def scope_query(scope, joins)
      self.joins(joins).where(joins => scope_query_params(scope))
    end

    def scope_query_params(scope)
      {target_type: scope.class.base_class.name, target_id: scope.id}
    end

    # attr_search (II) #########################################################
    def attr_group(set, attrs, input_group)
      input_group.merge!({'attrs' => attrs})
      attrs.any? ? set.where(attrs) : set
    end

    # hattr_search (III) #######################################################
    def hattr_group(set, hattrs, hstore, input_group)
      return default_search_results(set) if !hstore
      hattr_query_case(set, hattrs, hstore, input_group)
      input_group.merge!({'hattrs' => search_inputs(h['opt_set'], hattrs, hstore)})
    end

    # def hattr_search(set, search_params, hstore, input_group)
    #   return default_search_results(set) if !hstore
    #   #context = search_params.all?{|k,v| v.index(' All ')} ? :all : nil
    #   hattr_query_case(set, search_params.reject{|k,v| v.index(' All ')}, hstore, context, input_group)
    #
    #   input_group.merge!({'hattrs' => search_inputs(h['opt_set'], search_params, hstore)})
    # end

    def default_search_results(set)
      set == self ? [] : set
    end

    # hattr_search: hattr_query_case (a) #######################################
    # def hattr_query_case(set, search_params, context, hstore, input_group)
    #   opt_set = distinct_hstore(hattr_search_query(set, search_params, hstore))
    #   search_results = context ==  :all ? opt_set : []
    #   h.merge!({'opt_set'=> opt_set, 'search_results'=> search_results})
    # end
    def hattr_query_case(set, hattrs, hstore, input_group)
      opt_set = uniq_hattrs(hattr_search_query(set, hattrs, hstore))
      h.merge!({'opt_set'=> opt_set, 'search_results'=> opt_set})
    end

    # hattr_search: hattr_search_query (b) #####################################
    # def hattr_search_query(set, search_params, hstore)
    #   if search_params.empty?
    #     index_query(set, search_params.keys, hstore)
    #   else
    #     search_query(set, search_params, hstore)
    #   end
    # end
    def hattr_search_query(set, hattrs, hstore)
      if hattrs.empty?
        index_query(set, hattrs.keys, hstore)
      else
        search_query(set, hattrs, hstore)
      end
    end

    def index_query(set, keys, hstore)
      set.where("#{hstore}?& ARRAY[:keys]", keys: keys)
    end

    def search_query(set, search_params, hstore)
      set.where(search_params.to_a.map{|kv| query_params(kv[0], kv[1], hstore)}.join(" AND "))
    end

    def query_params(k,v, hstore)
      "#{hstore} -> \'#{k}\' = \'#{v}\'"
    end

    # hattr_search: distinct_hstore (c) ########################################
    
    def distinct_hstore(opt_set, list=[], set=[])
      opt_set.each do |i|
        assign_unique(i, list, set)
      end
      set
    end

    def assign_unique(item, list, set)
      h = item_search_keys.map{|k| [k, item.csv_tags[k]]}.to_h
      return if list.include?(h)
      list << h
      set << item
    end

    def search_inputs(opt_set, search_params, hstore, h={})
      search_params.each do |k,v|
        h.merge!({k=>{'opts'=> select_input_opts(opt_set, k, hstore), 'selected'=>v}})
      end
      h
    end

    # don't prepend: add js function for 'all'
    def select_input_opts(opt_set, k, hstore)
      opt_set.map{|i| i.public_send(hstore)[k]}.uniq.compact.prepend('-- All --')
    end

  end
end
