class LimitedEdition
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable

  def self.attrs
    {kind: 2, type: 1, field_name: -1}
  end

  def self.config_numbering(k, tb_hsh, numbering_hsh, input_group, context)
    config_edition(tb_hsh, numbering_hsh, context, input_group[:attrs])
  end

  def self.config_edition(tb_hsh, edition_hsh, context, attrs)
    if context[:proof_edition]
      config_proof_edition(tb_hsh, attrs)
    else
      config_numbered_edition(tb_hsh, edition_hsh, context, attrs)
    end
  end

  def self.config_proof_edition(tb_hsh, attrs)
    tb_hsh['search_tagline'] = tb_hsh['tagline'].sub('Edition', 'Ed')
    tb_hsh['invoice_tagline'] = tb_hsh['search_tagline']
    attrs['edition'] = tb_hsh['search_tagline'].split(' ')[2..3].join(' ')
  end

  def self.config_numbered_edition(tb_hsh, edition_hsh, context, attrs)
    attrs['edition'] = tb_hsh['tagline'].sub('Numbered', 'No')
    tb_hsh['invoice_tagline'] = attrs['edition']
    update_numbering(tb_hsh, edition_hsh, attrs)
    tb_hsh['search_tagline'] = attrs['edition']
    Item.new.transform_params(tb_hsh, 'and', 1) if context[:numbered_signed]
  end

  def self.update_numbering(tb_hsh, edition_hsh, attrs)
    if edition_hsh.keys.count==2
      attrs['numbering'] = edition_hsh.values.join('/')
      tb_hsh.transform_values!{|tag_val| [tag_val, attrs['numbering']].join(' ')}
    elsif edition_hsh.values[0] && edition_hsh.values[0].index('/')
      attrs['numbering'] = edition_hsh.values[0]
      tb_hsh.transform_values!{|tag_val| [tag_val, attrs['numbering']].join(' ')}
    end
  end

  # def self.numbering_context(k, f_name, context)
  #   context[f_name.to_sym] = true if %w[proof_edition numbered].include?(f_name)
  # end

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


  # def self.config_numbering(k, numbering_hsh, input_group, context, d_hsh)
  #   tb_hsh = Item.new.slice_valid_subhsh!(numbering_hsh, *Item.new.tb_keys)
  #   config_edition(tb_hsh, numbering_hsh, context, input_group[:attrs])
  #   d_hsh[k] = tb_hsh
  #   #d_hsh.merge!({k=>tb_hsh})
  # end

  # def self.config_numbered_edition(tb_hsh, edition_hsh, context, attrs)
  #   attrs['edition'] = tb_hsh['tagline'].sub('Numbered', 'No')
  #   edition_hsh.keys.count<2 ? tb_hsh : tb_hsh.transform_values!{|tag_val| [tag_val, edition_hsh.values.join('/')].join(' ')}
  #   Item.new.transform_params(tb_hsh, 'and', 1) if context[:numbered_signed]
  #   tb_hsh['search_tagline'] = tb_hsh['tagline'].sub('Numbered', 'No')
  # end

  # def self.edition_numbering(edition_hsh)
  #   edition_hsh.values.join('/') if edition_hsh.keys.count == 2
  # end

  # def self.search_edition(d_hsh, attrs)
  #   if ed_val = d_hsh.dig("numbering", "tagline")
  #     attrs.merge!({'edition'=>ed_val.sub('Numbered', 'No')})
  #   end
  # end

  # def self.edition_value(edition_hsh)
  #   if edition_hsh.keys.count == 2
  #     edition_hsh.values.join('/')
  #   elsif edition_hsh.keys.include?('edition_size')
  #     "out of #{edition_hsh['edition_size']}"
  #   end
  # end
