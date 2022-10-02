class FieldItem < ApplicationRecord

  require 'json'
  include Fieldable
  include Crudable
  include TypeCheck

  has_many :item_groups, as: :origin
  validates :type, :field_name, presence: true

  def fattrs
  	[:kind, :type, :field_name].map{|attr| public_send(attr).underscore}
  end

  def add_and_assoc_targets(target_group, assoc)
  	add_targets(target_group, assoc).map{|target| assoc_unless_included(target)}
  end

  def add_targets(target_group, assoc)
  	target_group.map{|target_args| add_target(target_args, assoc)}
  end

  def add_target(target_args, assoc)
  	update_assocs(to_class(target_args[0]).where(field_name: target_args[2], kind: target_args[1]).first_or_create, assoc)
  end

  def update_assocs(target, assoc)
  	target.assocs = assign_or_merge(target.assocs, {assoc=>true})
  	target.save
    target
  end

  def self.to_csv(fields={})
  	CSV.generate(fields) do |csv|
      rows = column_names.reject{|column| %w[created_at updated_at field_assocs].include?(column)}
  		csv << rows
  		all.each do |field|
  			csv << field.attributes.values_at(*rows)
  		end
  	end
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
    field_item = find_by_id(row["id"]) || new
    field_item.attributes = config_hstore(row.to_hash)
    field_item.save!
    end
  end

  def self.config_hstore(row)
    %w[tags assocs].each_with_object(row) do |hstore, row|
      if row[hstore]
        #row[hstore] = Item.parse_str_hsh(row[hstore].gsub('"', '').gsub(/[{}]/,''))
        row[hstore] = Item.parse_str_hsh(row[hstore])
      end
    end
  end

  def self.seed
    Medium.class_group('FieldGroup').reverse.each_with_object({}) do |c, store|
      c.build_and_store(:targets, store)
    end
  end
end


# def self.hm_assocs
#   self.reflect_on_all_associations(:has_many).map{|assoc| assoc.name.to_s} #plural
# end
