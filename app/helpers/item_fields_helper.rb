module ItemFieldsHelper

  def input_label(f_hsh)
    label_case(Item.swap_str(f_hsh[:f_name].split('_').join(' '), ['standard', '', 'flat', '', ' one of one', '']), f_hsh[:k], f_hsh[:t])
  end

  def label_case(f_name, k, t)
    case
      when k == 'dimension' && t == 'select_menu'; 'dims'
      when k == 'mounting' && t == 'select_menu'; 'mnt'
      when swap_kind.include?(k); Item.swap_str(k, ['medium', 'med', 'material', 'mat', 'leafing', 'leaf', 'remarque', 'remq', 'signature', 'sign', 'embellishing', 'embl', 'certificate', 'cert', 'sculpture_type', 'sculp',])
      else Item.swap_str(f_name, swap_name)
    end
  end

  def swap_name
    ['edition type', 'ltd ed', 'numbering type', 'edtn', 'numbered', 'nmbrd', 'edition size', 'size', 'edition', 'nmbr', 'dated', 'dating', 'animator', 'anima', 'sports', 'sport', 'mounting width', 'mnt-w', 'mounting height', 'mnt-h', 'width', 'w', 'height', 'h', 'depth', 'd', 'sculpture', 'sculp', 'verification number', 'reg #', 'verification type', 'reg', 'severity', 'discl', 'damage', 'damg', 'border', 'brdr', 'matting', 'mtt', 'framing', 'frm']
  end

  def swap_kind
    %w[medium material leafing remarque signature embellishing certificate sculpture_type]
  end

  def disable_btn(v)
    "disabled" if v.blank?
  end

end
