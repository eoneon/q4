module Build

  def context_build(field_name:, type:, kind:, tags:nil, targets:[])
    fieldable = field_class[type].where(field_name: field_name, kind: kind, tags: tags).first_or_create
    targets.map{|target| fieldable.assoc_unless_included(target)}
    fieldable
  end

  def field_class
    {OPT: Option, RBTN: RadioButton, FSO: FieldSet, SFO: SelectField, SMO: SelectMenu, NF: NumberField, TF: TextField, TFA: TextAreaField}
  end

  ##############################################################################
  
  def cascade_build(store: {}, type: name.to_sym)
    constants.each do |k|
      store[k] = get_opts(k)
    end
    {type => store}
  end

  def cascade_assoc(store:, type: name.to_sym)
    constants.each do |k|
      get_opts(k).each do |key, key_set|
        # type: :field_type alias
        # k: :kind
        # key: :field_name
        #
        # extract targets from store hash
        store.dig(*key_set)
      end
    end
  end

  def get_opts(k)
    [self,k].join('::').constantize.opts
  end

  # def get_assocs(store,k)
  #   store.dig(*get_opts(k))
  # end

end
