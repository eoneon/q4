require 'active_support/concern'

module ClassContext
  extend ActiveSupport::Concern

  class_methods do

    ############################################################################
    def build_and_store(m, store)
      desc_select(m: m).each_with_object(store){|c, store| c.builder(store)}
    end

    def merge_asc_selected_hash_methods(m)
      h = asc_select(m).each_with_object({}) do |c, h|
        h.merge!(c.public_send(m))
      end
    end

    def asc_detect_with_methods(meths, asc_test=:method_exists?)
      h = meths.each_with_object({}) do |m, h|
        asc_detect_and_merge(h, m, asc_test)
      end
    end

    def asc_detect_and_merge(h, m, asc_test)
      if c = asc_detect(m, asc_test)
        h.merge!({m => c})
      end
    end

    ############################################################################
    ############################################################################
    def asc_detect_methods_call_and_merge(meths:, asc_test: :method_exists?)
      h = meths.each_with_object({}) do |m, h|
        asc_detect_call_and_merge(h, m, asc_test) #if public_send(asc_test, m)
      end
    end

    def asc_detect_call_and_merge(h, m, asc_test)
      if c = asc_detect(m, asc_test)
        h.merge!({m => c.public_send(m)})
      end
    end
    ############################################################################
    ############################################################################

    ############################################################################
    ############################################################################
    def asc_select_methods_call_and_merge(meths:)
      h = meths.each_with_object({}) do |m, h|
        asc_select_call_and_merge(h, m) 
      end
    end

    def asc_select_call_and_merge(h, m)
      asc_select(m).each_with_object(h){|c| case_merge(h, m, c.public_send(m))}
    end
    ############################################################################
    ############################################################################



    ############################################################################

    def desc_select_field_with_attrs_tags_targets_and_assocs(m)
      desc_select(m: m).each_with_object([]) do |c, set|
        attrs = c.build_attrs(:attrs)
        set.append({attrs: attrs, tags: c.build_tags(attrs), assocs: c.build_assocs(:origin, :set, :group), targets: c.targets})
      end
    end

    ############################################################################
    #SELECT/DETECT CLASSES: ASC/DESC using: method_exists?(method)/respond_to?(method)
    def desc_select(test_m: :method_exists?, m:, set:[])
      public_send(test_m, m) ? set.append(self) : subclasses.each_with_object(set) {|c, set| c.desc_select(m: m, set: set)}
    end

    def asc_select(m, test_m=:method_exists?)
      class_tree.select{|c| c.public_send(test_m, m)}
    end

    def asc_detect(m, test_m=:method_exists?)
      class_tree.detect{|c| c.public_send(test_m, m)} #&& !c.public_send(m).blank?
    end

    def desc_select_then_asc_detect(desc_m, asc_m, asc_test)
      desc_select(m: desc_m).each_with_object([]) do |c, set|
        if asc_c = c.asc_detect(asc_m, asc_test)
          set.append(asc_c) if set.exclude?(asc_c)
        end
      end
    end

    def desc_select_asc_detect_and_call(desc_m, asc_m, asc_test)
      desc_select_then_asc_detect(desc_m, asc_m, asc_test).each_with_object({}) do |c, h|
        h.merge!({c.const.to_sym => c.public_send(asc_m)})
      end
    end

    def desc_select_then_asc_select(desc_m, asc_m, asc_test)
      desc_select(m: desc_m).each_with_object([]) do |c, set|
        if asc_c = c.asc_select(asc_m, asc_test)
          set.append(asc_c) if set.exclude?(asc_c)
        end
      end
    end

    ############################################################################

    def class_tree
      (0..const_tree.count-1).map{|i| const_tree[0..i].join('::').constantize}.reverse
    end

    def const_tree
      to_s.split('::')
    end

    def const(i=-1)
      const_tree[i]
    end

    ############################################################################

    def to_class(f_type)
      f_type.to_s.classify.constantize
    end

    def dig_fields(target_sets, store)
      target_sets.map{|f_keys| store.dig(*f_keys)}.flatten
    end

    def method_exists?(method)
      methods(false).include?(method)
    end

    def build_opts(set, k, k2)
      set.map{|k3| [k, k2, k3]}
    end

    ############################################################################

    def detect_file(set, folder)
      set.detect{|i| classified_files(folder).include?(i)}
    end

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

############################################################################
# def asc_detect_and_call(meth)
#   if c = asc_detect_class(meth)
#     c.public_send(meth)
#   end
# end

# def merge_assocs(meth)
#   desc_select_classes(:respond_to?, meth).each_with_object({}) do |c, h|
#     c.subclasses.none? ? collect_assocs(c, h) : c.subclasses.each_with_object(h){|c2,h | collect_assocs(c2, h)}
#   end
# end

# def detect_method(meth, class_tree)
#   class_tree.detect{|c| c.method_exists?(meth)}
# end

# def merge_assocs(meth)
#   desc_select_classes(:respond_to?, meth).each_with_object({}) do |c, h|
#     c.subclasses.none? ? collect_assocs(c, h) : c.subclasses.each_with_object(h){|c2,h | collect_assocs(c2, h)}
#     # if c.subclasses.none?
#     #   collect_assocs(c, h)
#     # else
#     #   c.subclasses.each_with_object(h){|c2,h | collect_assocs(c2, h)}
#     # end
#   end
# end
