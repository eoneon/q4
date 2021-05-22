require 'active_support/concern'

module ClassContext
  extend ActiveSupport::Concern

  class_methods do
    def class_cascade(store)
      if subclasses.any?
        cascade_subclasses(store)
      else
        cascade_build(store)
      end
    end

    def cascade_subclasses(store)
      subclasses.each do |klass|
        klass.class_cascade(store)
      end
    end

    ############################################################################

    # def f_attrs(*idxs)
    #   idxs.map{|i| const_tree[i]}
    # end

    # def f_attrs
    #   vals = [:kind, :type, :subkind].each_with_object([]) do |meth, vals|
    #     if c = detect_method(meth, class_tree)
    #   subkind = detect_and_call(:subkind, class_tree)
    #   f_type = detect_file(const_tree, 'FieldItem')
    #   kind = detect_file(const_tree, 'FieldGroup')
    #   [kind, f_type, subkind, const]
    # end

    # def f_attrs(class_tree, *meths)
    #   h = meths.each_with_object({}) do |meth, h|
    #     if val = detect_and_call(meth, class_tree)
    #       h[meth] = val
    #     end
    #   end
    # end

    def f_attrs(class_tree, *meths)
      h = meths.each_with_object({}) do |meth, h|
        if idx = detect_and_call(meth, class_tree)
          h[meth] = const_tree[idx]
        end
      end
    end

    def detect_file(set, folder)
      set.detect{|i| classified_files(folder).include?(i)}
    end

    ############################################################################

    # def build_tags(args:, tag_set:, class_set:)
    #   tags = tag_set.each_with_object({}) do |meth, tags|
    #     if c = detect_method(meth, class_set)
    #       tags.merge!({meth.to_s => c.public_send(meth, *args.values)})
    #     end
    #   end
    # end

    def build_tags(args, *methods)
      tags = detect_classes_from_tree(methods).each_with_object({}) do |(m,c), tags|
        tags.merge!({m => c.public_send(m, args)})
        #h.each{|m,c| tags.merge{m => c.public_send(m, args)}}
      end
    end

    # def build_tags(args, tag_methods)
    #   tags = tag_methods.each_with_object({}) do |m, tags|
    #     if c = detect_method(m, class_tree)
    #       tags.merge!({m.to_s => c.public_send(m, args)})
    #     end
    #   end
    # end

    def detect_and_call(meth, class_tree)
      if c = detect_method(meth, class_tree)
        c.public_send(meth)
      end
    end

    def detect_method(meth, class_tree)
      class_tree.detect{|c| c.method_exists?(meth)}
    end

    ######################
    # def filtered_class_tree(n, n2, meth)
    #   class_tree(n,n2).select{|klass| klass.method_exists?(meth)}
    # end
    def collect_params(params)
      merge_selected_hashes_from_tree(params).each_with_object({}){|(attr,idx), h| h.merge!({attr => const_tree[idx]}) }
      # h = attrs.each_with_object({}) do |(attr,idx), h|
      #   h[attr] = const_tree[idx]
      # end
    end

    def merge_selected_hashes_from_tree(method)
      h = select_classes_from_tree(method).each_with_object({}) do |c, h|
        h.merge!(c.public_send(method))
      end
    end

    def select_classes_from_tree(meth)
      class_tree.select{|c| c.method_exists?(meth)}
    end

    def detect_classes_from_tree(methods)
      h = methods.each_with_object({}) do |m, h|
        if c = detect_method(m, class_tree)
          h.merge!({m => c})
        end
      end
    end
    # def detected_class_tree(meth)
    #   class_tree.select{|c| c.method_exists?(meth)}
    # end

    # def class_tree(n,n2)
    #   (n..n2).map{|i| const_tree[0..i].join('::').constantize}.reverse
    # end

    def class_tree
      (0..const_tree.count-1).map{|i| const_tree[0..i].join('::').constantize}.reverse
    end

    def const_tree
      to_s.split('::')
    end

    def const(i=-1)
      const_tree[i]
    end

    ######################

    def to_class(f_type)
      f_type.to_s.classify.constantize
    end

    def dig_fields(target_sets, store)
      target_sets.map{|f_keys| store.dig(*f_keys)}.flatten
    end

    # def detect_method(meth, class_set)
    #   class_set.detect{|c| c.method_exists?(meth)}
    # end

    def method_exists?(method)
      methods(false).include?(method)
    end

    def build_opts(set, k, k2)
      set.map{|k3| [k, k2, k3]}
    end

    ######################
    def class_group(folder)
      classified_files(folder).map{|c| c.constantize}
    end

    def classified_files(folder)
      dir_files(folder).map{|c| c.classify}
    end

    def dir_files(folder)
      Dir.glob("#{Rails.root}/app/models/#{folder.underscore}/*.rb").map{|path| path.split("/").last.split(".").first}.delete_if{|f| f == folder.underscore}
    end
  end
end
