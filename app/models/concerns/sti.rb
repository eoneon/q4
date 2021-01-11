require 'active_support/concern'

module STI
  extend ActiveSupport::Concern

  #relations, callbacks, validations, scopes and others...######################

  included do
    before_destroy :remove_dependent_item_groups
  end

  # module Leafing
  #   def self.opts
  #     {
  #       Leafing: ['gold leaf', 'hand laid gold leaf', 'silver leaf', 'hand laid silver leaf', 'hand laid gold and silver leaf', 'hand laid copper leaf']
  #     }
  #   end
  # end

  #one more refactor ###########################################################

  #subclass methods ############################################################
  def scoped_targets(scope:, join:, sort: nil, reject_set:[])
    scoped_targets_through_join(valid_join_targets(scope, join, sort, reject_set))
  end

  def scoped_targets_through_join(join_set)
    join_set.includes(:target).map(&:target).flatten
    #join_set.includes(target: :item_groups).map{|i| i.target}
  end

  #=> #<ActiveRecord::AssociationRelation [ItemGroup...]>
  def valid_join_targets(scope, join, sort, reject_set)
     public_send(join).order(sort).where(target_type: valid_assocs(scope, reject_set).map{|k| k.classify})
     #targets.where(target_type: valid_assocs(scope, reject_set).map{|k| k.classify})
     # sm.targets.includes(:target)
  end

  #=> ["select_menus", "field_sets", "select_fields", "options", "check_box_fields", "text_fields", "number_fields", "text_area_fields"]
  def valid_assocs(scope, reject_set)
    to_class.scoped_assocs(scope).select{|assoc| reject_set.exclude?(assoc.classify)}
  end

  #collection methods ##########################################################
  def scoped_sti_targets_by_type(scope:, rel: :has_one, reject_set: [])
    target_set = scoped_type_targets(scope, reject_set)
    child_set(target_set, rel) #if target_set.any?
  end

  def scoped_type_targets(scope, reject_set=[])
    targets.keep_if {|target| sti_obj?(target) && reject_obj?(reject_set, target) && target.base_type == scope}
  end

  def sti_obj?(obj)
    obj.class.method_defined?(:type)
  end

  def reject_obj?(reject_set, obj)
    reject_set.empty? || reject_set.exclude?(obj.type)
  end

  def child_set(target_set, rel)
    if rel == :has_one
      target_set[0]
    else
      target_set
    end
  end

  def targets
    sorted_targets.map{|item_group| item_group.target}
  end

  def sorted_targets
    #item_groups.order(:sort)
    item_groups.order(nil)
  end

  def remove_dependent_item_groups
    ItemGroup.where(origin_id: self.id).or(ItemGroup.where(target_id: self.id)).destroy_all
  end

  #AR class methods
  #AR obj: to_class -> expand re: Q3/models/concerns/build_set.rb
  def to_class
    self.class.name.constantize
  end

  def to_base_class
    self.class.base_class
  end

  def base_type
    to_base_class.name
  end

  def base_dir
    base_type.underscore.pluralize
  end

  def has_many_assoc_list
    to_class.assoc_names
  end

  #=> ["materials", "mountings"] -> need to kill
  def scoped_assoc_names
    to_class.scoped_assoc_names(to_base_class).map{|assoc| assoc}
  end

  #=> #<ActiveRecord::Associations::CollectionProxy []>
  def scoped_target_collection(assoc)
    self.public_send(assoc)
  end

  #this is similar to above except it converts an AR object to assoc method rather than a string or symbol: consolidate
  def target_collection(target)
    scoped_target_collection(target.class.name.underscore.pluralize)
  end

  def target_included?(target)
    self.target_collection(target).include?(target)
  end

  def assoc_unless_included(target)
    self.target_collection(target) << target unless self.target_included?(target)
  end

  # def assoc_unless_included_with_result(target)
  #   self.target_collection(target) << target unless self.target_included?(target)
  # end

  class_methods do

    #search methods ########################################################
    def tags_search(tag_params: [], default_set: nil, **param_rules)
      #tag_params = valid_params(tag_params, param_rules)
      tag_params = tag_params.reject {|tag_set| tag_set[-1] == 'all' || tag_set[-1].empty?}
      if tag_params.empty?
        alt_search(self, default_set)
      else
        self.where(tag_params.to_a.map{|params| build_query(params[0], params[1])}.join(" AND "))
      end
    end

    def alt_search(set, default_set)
      default_set.nil? ? [] : set.public_send(default_set)
    end

    def valid_params(tag_params, param_rules)
      if !param_rules.empty?
        param_rules.each {|method, test_set| public_send(method, tag_params, test_set)}
      end
      tag_params
    end

    def permit_keys(tag_params, permitted_keys)
      tag_params.keep_if! {|tag_set| permitted_keys.include?(tag_set[-1]) || !tag_set[-1].empty?}
    end

    def invalid_vals(tag_params, invalid_vals)
      tag_params.reject! {|tag_set| invalid_vals.include?(tag_set[-1]) || tag_set[-1].empty?}
    end

    def permit_vals(tag_params, test_set)
      tag_params.keep_if {|tag_set| test_set.include?(tag_set[0]) || !tag_set[-1].empty?}
    end

    def valid_vals(tag_params, vals)
      tag_params.reject {|tag_set| vals.include?(tag_set[-1]) || tag_set[-1].empty?}
    end

    #############################################

    def kv_set_search(kv_sets, set=self)
      if kv_sets.empty?
        kv_sets
      else
        set.where(kv_sets.to_a.map{|kv_set| build_query(kv_set[0],kv_set[1])}.join(" AND "))
      end
    end

    def kv_search(set,k,v)
      set.where(build_query(k,v))
    end

    def build_query(k,v)
      "tags -> \'#{k}\' = \'#{v}\'"
    end

    #controller methods ########################################################
    #param ex: target_hsh={:item_name => "canvas, paper, wood, metal"}
    def update_targets(target_hsh)
      set=[]
      target_hsh.keys.each do |k|
        find_or_create_target(k,target_hsh,set)
      end
      set
    end

    def find_or_create_target(k,target_hsh,set)
      if k.to_s.split("_").include?("name")
        find_or_create_by(target_hsh[k].split(","), k.to_sym, set)
      elsif k.to_s.split("_").include?("id")
        set << find(target_hsh[k])
      end
    end

    def find_or_create_by(name_set, k, set)
      name_set.each do |name|
        set << where(k.to_sym => name.strip).first_or_create
      end
      set
    end

    #build methods: normalize hstore field #####################################
    def update_tags(obj, tag_hsh)
      return if tag_hsh.blank? || tag_hsh.stringify_keys == obj.tags
      obj.tags = assign_or_merge(obj.tags, tag_hsh.stringify_keys)
      obj.save
    end

    def id_tags(tags, h={})
      unless tags.nil?
        %w[kind sub_kind].map{|k| h[k] = tags.stringify_keys[k] if tags.stringify_keys.has_key?(k)}.reject {|k,v| v.nil?}
      end
      h
    end

    def assign_or_merge(h, h2)
      h.nil? ? h2 : h.merge(h2)
    end

    #hash methods ##############################################################
    def nested_assign(kv_set, hsh, keys=[])
      kv_set.each_with_index do |kv,i|
        key = has_nested_key?(hsh, keys.append(kv[0]))
        nested_assign_kv(hsh, keys, key, kv[0], kv[1], i)
      end
      hsh
    end

    def nested_assign_kv(hsh, keys, key, k, v, i)
      if !key && keys.count == 1
        hsh[k] = v
      elsif !key && keys.count > 1
        keys[0..i-1].inject(hsh, :fetch)[k] = v
      end
    end

    def has_nested_key?(hsh, keys)
      hsh.dig(*keys)
    end

    #class context methods, i.e., Medium, Material,...##########################

    #get FILTERED superclass-specific assoc names; used by instance method above => ["materials", "mountings"]
    def scoped_assoc_names
      assoc_names.keep_if {|assoc| file_set.include?(assoc.singularize)}
    end

    #get ALL assoc names except join assoc; first param for: scoped_assoc_names #=> ["select_fields", "text_fields", "check_box_fields", "number_fields", "text_area_fields", "materials", "mountings"]
    def assoc_names
      self.reflect_on_all_associations(:has_many).map{|assoc| assoc.name.to_s}.reject {|i| i == 'item_groups'}
    end

    #superclass context methods: ProductItem, FieldItem ########################
    #search and scope methods ########################
    def type_search
      set=[]
      file_names.each do |file_name|
        set << hsh={scope: file_name.to_sym, type: to_type(file_name), text: to_text(file_name)}
      end
      set
    end

    def types
      type_search.map{|h| h[:type]}
    end

    def to_type(file_name)
      file_name.split("_").map{|word| word.capitalize}.join("")
    end

    def to_text(file_name)
      file_name.split("_").map{|word| word.capitalize}.join("-").pluralize
    end

    #get file names inside superclass directory; second param for: scoped_assoc_names (prepends file set with superclass file name: ["product_item",...] and ["field_item",...]) #=> => ["field_item", "select_field", "text_field", "number_field", "field_set", "radio_button", "option", "check_box_field", "text_area_field"]
    def file_set
      file_names.reject {|i| i == self.to_s.underscore}.prepend(self.to_s.underscore)
    end

    def file_names
      Dir.glob("#{Rails.root}/app/models/#{self.to_s.underscore}/*.rb").map {|path| path.split("/").last.split(".").first}
    end

    # refactored AR collection methods #########################################
    def scoped_assocs(scope)
      hm_assocs.select{|assoc| dir_files(scope).include?(assoc.singularize)}
    end

    def hm_assocs
      self.reflect_on_all_associations(:has_many).map{|assoc| assoc.name.to_s} #plural
    end

    def dir_files(folder)
      Dir.glob("#{Rails.root}/app/models/#{folder.underscore}/*.rb").map{|path| path.split("/").last.split(".").first}
    end

    def detect_option(set, options)
      set.detect{|i| options.include?(i)}
    end

  end
end
