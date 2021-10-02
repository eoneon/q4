module ItemFieldsHelper

  def input_label(f_hsh)
    if %w[material medium].include?(f_hsh[:k])
      f_hsh[:k]
    elsif f_hsh[:k].index('verification') && f_hsh[:t] == 'text_field'
      'verification#'
    elsif f_hsh[:f_name].index('dimension')
      'dimensions'
    elsif f_hsh[:f_name].index('embellishing')
      'embellishing'
    elsif f_hsh[:k] == 'mounting' && f_hsh[:t] == 'select_menu'
      f_hsh[:k]
    else
      Item.swap_str(f_hsh[:f_name].split('_').join(' '), ['standard', '', 'flat', '', 'mounting', ''])
    end
  end

end
