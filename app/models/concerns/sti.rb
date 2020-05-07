require 'active_support/concern'

module STI
  extend ActiveSupport::Concern

  class_methods do

    #h={:assoc=> target_hsh={:item_name=> "horse, dog, cat, mouse", :material_id=> id}}
    #target_hsh={:item_name => "horse, dog, cat, mouse"}
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

    ############################################################################

    #subclass method:
    #get assoc names scoped to superclass: ProductItem, FieldItem => ["materials", "mountings"]: should be named: scoped_assocs->scoped_assoc_names
    # def scoped_assoc_names(super_class)
    #   assoc_names.keep_if {|assoc| super_class.file_set.include?(assoc.singularize)}
    # end
    def scoped_assoc_names
      assoc_names.keep_if {|assoc| file_set.include?(assoc.singularize)}
    end

    #get all assoc names except join assoc: should be named: assoc->assoc_names
    def assoc_names
      self.reflect_on_all_associations(:has_many).map {|assoc| assoc.name.to_s}.reject {|i| i == 'item_groups'}
    end

    #superclass method: ProductItem, FieldItem
    #get file names inside superclass directory; prepend with superclass file name: ["product_item",...] and ["field_item",...]
    def file_set
      file_names.reject {|i| i == self.to_s.underscore}.prepend(self.to_s.underscore)
    end

    def file_names
      Dir.glob("#{Rails.root}/app/models/#{self.to_s.underscore}/*.rb").map {|path| path.split("/").last.split(".").first}
    end

  end

  #get all targets; add sort order later: should be named: all_targets->targets
  def targets
    item_groups.map {|item_group| item_group}
  end

  #AR obj: to_class
  def to_class
    self.class.name.constantize
  end

  def to_superclass
    self.class.superclass
  end

  def to_superclass_name
    to_superclass.name
  end

  #=> ["materials", "mountings"]: should really be named: target_assocs->scoped_assoc_names
  def scoped_assoc_names
    to_class.scoped_assoc_names(to_class.superclass).map{|assoc| assoc}
  end

  #=> #<ActiveRecord::Associations::CollectionProxy []>: should be named: targets->scoped_target_collection
  def scoped_target_collection(assoc)
    self.public_send(assoc)
  end
  #this is similar to above except it converts an AR object to assoc method rather than a string or symbol: consolidate
  def target_collection(target)
    scoped_target_collection(target.class.name.underscore.pluralize)
  end
end
