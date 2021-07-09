require 'active_support/concern'

module Textable
  extend ActiveSupport::Concern

  class_methods do

    def name_from_class(name, skip_list, edit_list)
      format_name(edit_name(class_to_cap(name, skip_list), edit_list))
    end

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

    def format_name(name)
      name.split(' ').map(&:strip).join(' ')
    end

    def indefinite_article(noun)
      %w[a e i o u].include?(noun.first.downcase) && noun.split('-').first != 'one' || noun == 'HC' ? 'an' : 'a'
    end

    def arr_to_text(arr)
      if arr.length == 2
        arr.join(" & ")
      elsif arr.length > 2
        [arr[0..-3].join(", "), arr[-2, 2].join(" & ")].join(", ")
      else
        arr[0]
      end
    end
  end
end
