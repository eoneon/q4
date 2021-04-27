module FieldKind
  # FieldKind.field_group FieldKind::Tags::Medium
  def self.field_group
    store = [Category].each_with_object({}) do |class_a, store|
      class_a.class_cascade(store)
    end
  end

  ##############################################################################
  ##############################################################################
  def add_field_and_assoc_targets(f_class:, f_name:, f_kind:, targets: nil, tags: nil)
    f = add_field(f_class, f_name, f_kind, tags)
    targets.map{|target| f.assoc_unless_included(target)} if targets
    f
  end

  def add_field(f_class, f_name, kind, tags=nil)
    f = f_class.where(field_name: f_name, kind: kind).first_or_create
    update_tags(f, tags)
    f
  end

  def add_targets(target_class, f_kind)
    targets.map{|f_name| add_field(target_class, f_name, f_kind)}
  end

  def update_tags(f, tags)
    return if tags.blank? || tags.stringify_keys == f.tags
    f.tags = assign_or_merge(f.tags, tags.stringify_keys)
    f.save
  end

  def build_tags(args:, tag_set:, class_set:)
    tags = tag_set.each_with_object({}) do |meth, tags|
      if klass = class_set.detect{|c| c.method_exists?(meth)}
        tags.merge!({meth.to_s => klass.public_send(meth, *args.values)})
      end
    end
  end

  def assign_or_merge(h, h2)
    h.nil? ? h2 : h.merge(h2)
  end

  def merge_field(dig_set, store)
    Item.param_merge(params: store, dig_set: dig_set)
  end
  ##############################################################################
  ##############################################################################

  def dig_and_assoc(f, targets, store)
    dig_fields(targets, store).map{|field| f.assoc_unless_included(field)}
  end

  ##############################################################################
  #STRING methods
  ##############################################################################

  def class_to_cap(class_word, skip_list=[])
    class_word.underscore.split('_').map{|word| cap_word(word, skip_list)}.join(' ')
  end

  def cap_word(word, skip_list)
    skip_list.include?(word) ? word : word.capitalize
  end

  def edit_name(name, edit_list)
    name = edit_list.each_with_object(name) do |word_set|
      name.sub!(word_set[0], word_set[1])
    end
  end

  def edit_list
    [['Standard',''], ['Reproduction',''], ['On Paper', ''], ['One Of A Kind', 'One-of-a-Kind'], ['Of One', ' 1/1']]
  end

  def format_name(name)
    name.split(' ').map(&:strip).join(' ')
  end
end
