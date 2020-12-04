module InvoicesHelper

  def invoice_keys
    [['sku'], ['artist_name', 'artist'], ['title'], ['search_tagline', 'tagline'], ['mounting_dimensions', 'mounting'], ['material_dimensions', 'dimensions'], ['numbering', 'edition'], ['qty'], ['retail']]
  end

  def table_row(csv_tags)
    if csv_tags.nil?
      invoice_keys[1..-1].map{|k| nil}
    else
      table_data(csv_tags)
    end
  end

  def table_data(csv_tags, row=[])
    invoice_keys[1..-1].each do |opts|
      row << csv_tags.dig(opts[0]) ? csv_tags.dig(opts[0]) : 'n/a'
    end
    row
  end

end
