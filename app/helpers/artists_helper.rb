module ArtistsHelper

  def artsit_edit_form_group
    rows=[]
    Artist.tag_field_sets.each do |row|
      rows << row.map{|f| {'name' => f, 'label'=> labeler(f), 'col' => col_size(f)}}
    end
    rows
  end

  def labeler(label)
    label.split('_').join(' ')
  end

  def col_size(field_name)
    case
      when field_name.split('_').include?('name'); 'col-4'
      when field_name.split('_').include?('tag'); 'col-12'
      else 'col-2'
    end
  end
end
