require 'active_support/concern'

module Search
  extend ActiveSupport::Concern

  class_methods do

    def search(joins_scope: nil, joins: nil, attrs:{}, hattrs: {params:{}, hstore: nil}, search_group:{})
      set = query_set(joins_scope, joins)
      search_group.merge!({'scope' => joins_scope.try(:id)})
      set = attr_search(set, attrs.reject{|k,v| v.blank?})
      search_group.merge!({'attrs' => attrs})
      set = hattr_search(set, hattrs[:params].reject{|k,v| v.blank?}, hattrs[:hstore], search_group)
      set
    end

    # join_search (I) ##########################################################
    def query_set(joins_scope, joins)
      joins && joins_scope ? join_targets(joins_scope, joins) : self
    end

    def join_targets(joins_scope, joins)
      self.joins(joins).where(joins => join_target_params(joins_scope))
    end

    def join_target_params(joins_scope)
      {target_type: joins_scope.class.base_class.name, target_id: joins_scope.id}
    end

    # attr_search (II) #########################################################
    def attr_search(set, attrs)
      attrs.any? ? set.where(attrs) : set
    end

    # hattr_search (III) #######################################################
    def hattr_search(set, search_params, hstore, search_group)
      return default_search_results(set) if !hstore
      context = context = search_params.all?{|k,v| v.index(' All ')} ? :all : nil
      hattr_query_case(set, search_params.reject{|k,v| v.index(' All ')}, hstore, context, search_group)

      search_group.merge!({'hattrs' => search_inputs(h['opt_set'], search_params, hstore)})
    end

    def default_search_results(set)
      set == self ? [] : set
    end

    # hattr_search: hattr_query_case (a) #######################################
    def hattr_query_case(set, search_params, context, hstore, search_group)
      opt_set = distinct_hstore(hattr_search_query(set, search_params, hstore))
      search_results = context ==  :all ? opt_set : []

      h.merge!({'opt_set'=> opt_set, 'search_results'=> search_results})
    end

    # hattr_search: hattr_search_query (b) #####################################
    def hattr_search_query(set, search_params, hstore)
      if search_params.empty?
        index_query(set, search_params.keys, hstore)
      else
        search_query(set, search_params, hstore)
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
