require 'active_support/concern'

module Context
  extend ActiveSupport::Concern

  class_methods do

    # scope methods ##############################################################
    def scope_context(*konstant_objs)
      set=[]
      konstant_objs.each do |konstant_obj|
        if konstant_obj.to_s.index('::')
          konstant_obj.to_s.split('::').map {|konstant| set << konstant}
        else
          set << format_constant(konstant_obj)
        end
      end
      set.join('::').constantize
    end

    def format_constant(konstant)
      konstant.to_s.split(' ').map {|word| word.underscore.split('_').map {|split_word| split_word.capitalize}}.flatten.join('')
    end

    # parse scope chain relative to self #########################################
    def klass_name
      slice_class(-1)
    end

    def slice_class(i=nil)
      i.nil? ? self.to_s : self.to_s.split('::')[i]
    end

    def split_class
      self.to_s.split('::')
    end

    # utility methods ############################################################
    def method_exists?(klass, method)
      klass.methods(false).include?(method)
    end

    def decamelize(camel_word, *delim)
      delim = delim.empty? ? ' ' : delim.first
      name_set = camel_word.to_s.underscore.split('_')
      name_set.join(delim)
    end

    # folder_nameectory & file methods ###################################################
    def file_names(*folders)
      Dir.glob("#{Rails.root}/app/models/#{folders.map{|folder| folder.to_s}.join('/')}/*.rb").map {|path| path.split("/").last.split(".").first}
    end

  end
end

# folder_nameectory & file methods ###################################################
# def file_names(*folders)
#   Dir.glob("#{Rails.root}/app/models/#{folders.map{|folder| folder.to_s}.join('/')}/*.rb").map {|path| path.split("/").last.split(".").first}
# end

# def slice_and_decamelize(i=nil, camel_word, *delim)
#   decamelize(slice_class(i), delim)
# end
