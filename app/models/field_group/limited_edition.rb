class LimitedEdition
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable

  def self.attrs
    {kind: 2, type: 1, f_name: -1}
  end

  # def self.config_numbering_params(k, tb_keys, context, d_hsh)
  #   numbering_hsh = Item.new.hsh_slice_and_delete(d_hsh, k)
  #   puts "numbering_hsh=>#{numbering_hsh}"
  #   edition_hsh = numbering_hsh.slice!(*tb_keys)
  #   puts "edition_hsh=>#{edition_hsh}"
  #   if edition_hsh.reject!{|k,v| v.blank?}.any?
  #     context[edition_hsh.keys.include?('proof_edition') ? :proof_edition : :numbered] = true
  #     if context[:numbered]
  #       if edition_value = edition_value(%w[edition edition_size].each_with_object({}){|f_key, ed_hsh| ed_hsh[f_key] = edition_hsh[f_key]}) #reorder
  # 	       numbering_hsh.transform_values{|tag_val| [tag_val, edition_value].join(' ')}
  #       end
  #     end
  #     d_hsh.merge!({k=> numbering_hsh})
  #   end
  # end
  def self.config_numbering(k, numbering_hsh, input_group, context, d_hsh)
    tb_hsh = Item.new.slice_valid_subhsh!(numbering_hsh, *Item.new.tb_keys)
    config_edition_hsh(context[:proof_edition], tb_hsh, numbering_hsh)
    Item.new.transform_params(tb_hsh, 'and', 1) if context[:numbered_signed]
    d_hsh.merge!({k=>tb_hsh})
  end

  def self.config_edition_hsh(proof_edition, tb_hsh, edition_hsh)
    if proof_edition || edition_hsh.keys.count<2
      tb_hsh
    else
      tb_hsh.transform_values!{|tag_val| [tag_val, edition_hsh.values.join('/')].join(' ')}
    end
  end

  def self.config_numbering_params(k, numbering_hsh, edition_hsh, context, attrs, d_hsh)
    tb_hsh = context[:proof_edition] || edition_hsh.keys.count<2 ? numbering_hsh : numbering_hsh.transform_values{|tag_val| [tag_val, edition_hsh.values.join('/')].join(' ')}
    search_tagline = swap_str((tb_hsh['tagline'].index('1/1') ? tb_hsh['tagline'] : numbering_hsh['tagline']), %w[Numbered No Edition Ed and &])
    tb_hsh.merge!({'search_tagline'=> search_tagline})
    Item.new.transform_params(tb_hsh, 'and', 1) if context[:numbered_signed]
    d_hsh.merge!({k=>tb_hsh})
  end

  def self.edition_value(edition_hsh)
    edition_hsh.values.join('/') if edition_hsh.keys.count == 2
  end

  # def self.config_numbering_params(k, numbering_hsh, edition_hsh, context, attrs, d_hsh)
  #   puts "numbering_hsh=>#{numbering_hsh}, edition_hsh=>#{edition_hsh}"
  # 	edition_value = edition_value(edition_hsh) if edition_hsh.any?
  # 	numbering = edition_value ? numbering_hsh.transform_values{|tag_val| [tag_val, edition_value].join(' ')} : numbering_hsh
  #   puts "numbering=>#{numbering}"
  # 	search_edition_value = edition_value == '1/1' ? numbering['tagline'] : numbering_hsh['tagline']
  #   Item.new.transform_params(d_hsh[k], 'and', 1) if context[:numbered_signed]
  # 	d_hsh.merge!({k=> numbering.merge!({'search_tagline'=> search_edition_value})})
  # 	#context[edition_hsh.keys.include?('proof_edition') ? :proof_edition : :numbered] = true
  #   #search_edition(d_hsh, attrs)
  # end

  # def self.edition_value(edition_hsh)
  #   if edition_hsh.keys.count == 2
  #     edition_hsh.values.join('/')
  #   elsif edition_hsh.keys.include?('edition_size')
  #     "out of #{edition_hsh['edition_size']}"
  #   end
  # end

  def self.search_edition(d_hsh, attrs)
    if ed_val = d_hsh.dig("numbering", "tagline")
      attrs.merge!({'edition'=>ed_val.sub('Numbered', 'No')})
    end
  end

  def self.numbering_context(f_name, context)
    if f_name == 'proof_edition'
      context[f_name.to_sym] = true
    elsif f_name == 'edition'
      context[:numbered] = true
    end
  end

  class SelectField < LimitedEdition
    class Numbering < SelectField
      def self.swap_list
        ['Proof', '', 'One Of One', '1/1']
      end

      def self.editions(edition_type)
        set = [nil, 'AP', 'EA', 'CP', 'GP', 'PP', 'IP', 'HC', 'TC'].each_with_object([]) do |edition, set|
          next if edition_type == 'Edition' && edition.nil?
          set.append(build_edition(edition, edition_type).join(' '))
        end
      end

      def self.build_edition(edition, edition_type)
        edition_type == 'Edition' ? ['from', indefinite_article(edition), edition, edition_type] : [edition, edition_type].compact
      end

      def self.target_tags(f_name)
        {tagline: str_edit(str: f_name, skip: %w[from a an of]), body: f_name}
      end

      def self.body(f_name)
        f_name.split(' ').map{|word| word.split('').all?{|char| is_upper?(char)} ? word : word.downcase}.join(' ')
      end

      class Numbered < Numbering
        def self.targets
          editions(const.downcase)
        end
      end

      class RomanNumbered < Numbering
        def self.targets
          editions(str_edit(str: uncamel(const), skip:['Roman'], cntxt: :downcase))
        end
      end

      class NumberedOneOfOne < Numbering
        def self.targets
          editions(str_edit(str: uncamel(const), skip:['Roman'], swap: swap_list, cntxt: :downcase))
        end
      end

      class ProofEdition < Numbering
        def self.targets
          editions(str_edit(str: uncamel(const), swap: swap_list, cntxt: :downcase))
        end
      end

      # class BatchEdition < Numbering
      #   def self.targets
      #     ['from an edition of']
      #   end
      # end
    end
  end

  class FieldSet < LimitedEdition
    class Numbering < FieldSet
      class Numbered < Numbering
        def self.targets
          [%W[SelectField Numbering Numbered], %W[NumberField Numbering Edition], %W[NumberField Numbering EditionSize]]
        end
      end

      class RomanNumbered < Numbering
        def self.targets
          [%W[SelectField Numbering Numbered], %W[TextField Numbering Edition], %W[TextField Numbering Edition]]
        end
      end

      class ProofEdition < Numbering
        def self.targets
          [%W[SelectField Numbering ProofEdition]]
        end
      end
    end
  end

  class SelectMenu < LimitedEdition
    class Numbering < SelectMenu
      class NumberingType < Numbering
        def self.targets
          build_target_group(%W[Numbered RomanNumbered ProofEdition], 'FieldSet', 'Numbering')
        end
      end
    end
  end
end
