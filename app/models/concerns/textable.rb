require 'active_support/concern'

module Textable
  extend ActiveSupport::Concern

  class_methods do

    def str_edit(str:, swap:[], skip:[], cntxt: :capitalize)
      swap_str(str, swap).split(' ').map{|substr| cap_case(substr,skip,cntxt)}.join(' ')
    end

    def swap_str(str, swap_sets)
      strip_space(trans_args(swap_sets).inject(str) {|str, replace_this_with_that| str.sub(*replace_this_with_that)})
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

    def char_limit(str, abbrv_set, limit)
      return str if str.nil? || str.length<limit || abbrv_set.empty?
      set = abbrv_set.slice!(0)
      str.gsub!(*set)
      char_limit(str, abbrv_set, limit)
    end

    def inject_swap(str, swap_sets)
      strip_space(swap_sets.inject(str) {|str, replace_this_with_that| str.gsub(*replace_this_with_that)})
    end

    def detect_swap(str, swap_sets)
      if swap_set = swap_sets.detect{|swap_set| str.index(swap_set[0])}
        strip_space(str.sub(*swap_set))
      else
        str
      end
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

    def str_hsh_to_arr(str_hsh)
      ['[', ']'].inject(str_hsh){|v, i| v.gsub(i, ' ').strip}.split(' ')
    end

    def parse_str_hsh(str, start_idx=0)
      str.gsub!(/[{}"]/,'')
	    str_idxs(str,'=>')[1..-1].map{|i| str[0..i].rindex(/\s/)}.each_with_object([]) {|i,a| a << str[start_idx..i-2].split('=>'); start_idx = i+1}.append(str[start_idx..-1].split('=>')).to_h if str
    end

    def str_idxs(str,substr)
      str.enum_for(:scan, /(?=#{substr})/).map{Regexp.last_match.offset(0).first}  #str.enum_for(:scan, /(?==>)/).map{Regexp.last_match.offset(0).first}
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


# def input_label(f_hsh)
#   if material?(f_hsh[:k]) || medium?(f_hsh[:k])
#     f_hsh[:k]
#   elsif f_hsh[:f_name].index('dimension')
#     'dimensions'
#   elsif mounting?(f_hsh[:k]) && select_menu?(f_hsh[:t])
#     f_hsh[:k]
#   else
#     swap_str(f_hsh[:f_name].split('_').join(' '), ['standard', '', 'flat', '', 'mounting', ''])
#   end
# end
