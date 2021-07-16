require 'active_support/concern'

module Textable
  extend ActiveSupport::Concern

  class_methods do

    def str_edit(str:, swap:[], skip:[], cntxt: :capitalize)
      swap_str(str, swap).split(' ').map{|substr| cap_case(substr,skip,cntxt)}.join(' ')
    end

    def swap_str(str, swap_sets)
      strip_space(trans_args(swap_sets).each_with_object(str) {|replace_this_with_that,str| str.sub!(*replace_this_with_that)})
    end

    def cap_case(words, skip_set, cntxt)
      strip_space(words).split(' ').map{|str| format_cap_word(str,skip_set,cntxt)}.join(' ')
    end

    def format_cap_word(words, skip_set, cntxt)
      words.split(' ').map{|str| is_upper?(str) || skip_set.include?(str) ? str : nested_format_cap(str, cntxt)}.join(' ')
    end

    def nested_format_cap(str, cntxt)
      str[0] == '(' ? '('+str[1..-1].public_send(cntxt) : str.public_send(cntxt)
    end

    ############################################################################
    
    def uncamel(class_word)
      class_word.underscore.split('_').map{|str| str.capitalize}.join(' ')
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

    def strip_space(str)
      str.split(' ').map(&:strip).join(' ')
    end

    ############################################################################

    def is_acronym?(word)
      word.split('').all?{|char| is_upper?(char)}
    end

    def is_upper?(word)
      /[[:upper:]]/.match(word[0])
    end

    ############################################################################

    def trans_args(arg_list)
      arg_list.each_with_object({a:[],b:[]}) {|i,args| arg_list.index(i).even? ? args[:a].append(i) : args[:b].append(i)}.values.transpose
    end

  end
end
