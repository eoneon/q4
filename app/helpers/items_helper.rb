module ItemsHelper

  def field_set_rows(fs_hsh, rows=[])
    row_assocs.each do |row_key|
      field_row = field_set_row(fs_hsh, row_key_sets.assoc(row_key).last) #fs_hsh, %w[k,...]
      next if field_row.empty?
      rows << field_row
    end
    rows 
  end

  def field_set_row(fs_hsh, key_sets, hsh={})
    key_sets.each do |k| #'dimension'
      next if fs_hsh.keys.exclude?(k)
      hsh[k] = fs_hsh[k]
    end
    hsh
  end

  def row_assocs
    [:dimension, :mounting, :sub_media, :numbering, :authentication]
  end

  def row_key_sets
    [[:dimension, %w[dimension]], [:mounting, %w[mounting]], [:sub_media, %w[leafing remarque]], [:numbering, %w[numbering]], [:authentication, %w[signature certificate]]]
  end

end
