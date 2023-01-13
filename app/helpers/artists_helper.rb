module ArtistsHelper

  def artist_form_row(row)
    row.map{|f_name| {'name' => f_name, 'label'=> f_name, 'col' => col_size(f_name)}}
  end

  # def col_size(f_name)
  #   %w[title body].include?(f_name) ? 'col-6' : 'col-2'
  # end

  def col_size(f_name)
    if %w[title body].include?(f_name)
      'col-6'
    elsif %w[yob yod].include?(f_name)
      'col-2'
    else
      'col-1'
    end
  end
end

# def artist_form_group
#   Artist.tag_fields.each_with_object([]) do |row, rows|
#     rows << row.map{|f_name| {'name' => f_name, 'label'=> f_name, 'col' => col_size(f_name)}}
#   end
# end

# def labeler(label)
#   label.split('_').reject{|word| word== 'tag'}.join(' ')
# end

#f_name.split('_').include?('tag') ? 'col-6' : 'col-3'
