require 'active_support/concern'

module STI
  extend ActiveSupport::Concern

  #relations, callbacks, validations, scopes and others...######################

  included do
    before_destroy :remove_dependent_item_groups
  end

  #subclass methods ############################################################

  def remove_dependent_item_groups
    ItemGroup.where(origin_id: self.id).or(ItemGroup.where(target_id: self.id)).destroy_all
  end

  #get ALL targets; add sort order later: should be named: all_targets->targets
  def sorted_targets
    item_groups.order(:sort)
  end

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

  #=> ["materials", "mountings"]
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

  class_methods do
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
      if k.to_s.split("_").include?("name") #&& !target_hsh[k].blank?
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

    #class context methods, i.e., Medium, Material,...##########################

    #get FILTERED superclass-specific assoc names; used by instance method above => ["materials", "mountings"]
    def scoped_assoc_names
      assoc_names.keep_if {|assoc| file_set.include?(assoc.singularize)}
    end

    #get ALL assoc names except join assoc; first param for: scoped_assoc_names #=> ["select_fields", "text_fields", "check_box_fields", "number_fields", "text_area_fields", "materials", "mountings"]
    def assoc_names
      self.reflect_on_all_associations(:has_many).map {|assoc| assoc.name.to_s}.reject {|i| i == 'item_groups'}
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

  end
end
