require 'active_support/concern'

module CSVSeed
  extend ActiveSupport::Concern

  def config_assocs(targets)
  	self.assocs = targets.each_with_object({}).each_with_index {|(target,h),i| h[i+1] = assoc_val(target)}
    self.save
  end

  def assoc_val(target)
  	(target.class==Array ? ['Option', target[1], target[0]] : field_assoc(target)).join('::')
  end

  def field_assoc(f)
  	%w[type kind field_name].map{|attr| f.public_send(attr)}
  end

  def build_field_assocs
    all.select{|f| f.assocs && f.assocs.any?}.map {|f| f.assoc_fields}
  end

  def build_field_assocs
    all.select{|f| f.assocs && f.assocs.any?}.map {|f| assoc_fields(f)}
  end

  class_methods do

    def to_csv(set={})
      CSV.generate(set) do |csv|
        csv << filtered_columns
        all.each do |obj|
          csv << obj.attributes.values_at(*filtered_columns)
        end
      end
    end

    def import(file)
      CSV.foreach(file.path, headers: true) do |row|
        obj = find_by_id(row["id"]) || new
        obj.attributes = config_hstore(row.to_hash)
        obj.save!
      end
    end

    def filtered_columns
      column_names.reject{|column| %w[created_at updated_at field_assocs].include?(column)}
    end

    def config_hstore(row)
      %w[tags assocs].each_with_object(row) do |hstore, row| #each_with_object(row).select{|k,v| %w[tags assocs].include?(k) && v.present?} do |hstore, row|
        if row[hstore].present? && row[hstore] !="{}"
          row[hstore] = Item.parse_str_hsh(row[hstore])
        end
      end
    end

    def build_field_assocs
      all.select{|f| f.assocs && f.assocs.any?}.map {|f| assoc_fields(f)}
    end

    def assoc_fields(f)
      f.assocs.transform_keys{|k| k.to_i}.sort_by{|k,v| k}.map{|assoc| build_assoc(f, *assoc[1].split('::'))}
    end

    def build_assoc(f, t, k, f_name)
      f.assoc_unless_included(f.to_class(t).where(kind: k, field_name: f_name).first_or_create)
    end
  end

end
