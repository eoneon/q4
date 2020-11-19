module InvoicesHelper

  def invoice_keys
    [['sku'], ['artist_name', 'artist'], ['title'], ['search_tagline', 'tagline'], ['mounting_dimensions', 'mounting'], ['material_dimensions', 'dimensions'], ['numbering', 'edition'], ['qty'], ['retail']]
  end

  def invoice_media(csv_tags, rows=[])
    invoice_keys[1..-1].each do |opts|
      rows << csv_tags.dig(opts[0]) ? csv_tags.dig(opts[0]) : 'n/a'
    end
    rows
  end
  
end
