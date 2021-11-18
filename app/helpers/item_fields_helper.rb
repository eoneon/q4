module ItemFieldsHelper

  def input_label(f_hsh)
    label_case(Item.swap_str(f_hsh[:f_name].split('_').join(' '), ['standard', '', 'flat', '', ' one of one', '']), f_hsh[:k], f_hsh[:t])
  end

  def label_case(f_name, k, t)
    case
      when k == 'dimension' && t == 'select_menu'; 'dim type'
      when k == 'mounting' && t == 'select_menu'; k
      when kind_list.include?(k); k
      when swap_kind.include?(k); Item.swap_str(k, ['embellishing', 'embellish', 'certificate', 'cert'])
      else Item.swap_str(f_name, swap_name)
    end
  end

  def swap_name
    ['edition type', 'ltd type', 'numbering type', 'ed type', 'numbered', 'numbr type', 'edition size', 'ed size', 'edition', 'ed numbr', 'dated', 'date type', 'animator', 'anima', 'sports', 'sport', 'mounting width', 'mnt width', 'mounting height', 'mnt height', 'sculpture', 'sculp', 'verification number', 'reg numbr', 'verification type', 'reg type']
  end

  def kind_list
    %w[medium material leafing remarque signature]
  end

  def swap_kind
    %w[embellishing certificate]
  end

  def disable_btn(v)
    "disabled" if v.blank?
  end 

end
