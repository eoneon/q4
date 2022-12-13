class Submedium
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable

  def self.attrs
    {kind: 2, type: 1, field_name: -1}
  end

  def self.config_leafing(k, tb_hsh, k_hsh, input_group, context)
    if context[:remarque]
      Item.new.transform_params(tb_hsh, 'and', 1)
    else
      tb_hsh
    end
  end

  def self.config_remarque(k, tb_hsh, k_hsh, input_group, context)
    config_submedia(k, tb_hsh, input_group, context)
  end

  def self.config_submedia(k, tb_hsh, input_group, context)
    k=='leafing' ? config_leafing_params(context, tb_hsh) : config_remarque_params(context, tb_hsh)
  end

  def self.config_leafing_params(tb_hsh, context)
    puts "context[:leafing_remarque]=>#{context[:leafing_remarque]}"
    Item.new.transform_params(tb_hsh, 'and', 1) if context[:leafing_remarque]
  end

  def self.config_remarque_params(context, tb_hsh)
    Item.new.transform_params(tb_hsh, 'with') if !context[:leafing]
  end

  class SelectField < Submedium
    class Embellishing < SelectField
      def self.target_tags(f_name)
        {tagline: str_edit(str: uncamel(f_name)), body: f_name}
      end

      class StandardEmbellishing < Embellishing
        def self.targets
          ['hand embellished', 'hand painted', 'artist embellished']
        end
      end

      class PaperEmbellishing < Embellishing
        def self.targets
          ['hand embellished', 'hand painted', 'hand colored', 'hand watercolored', 'hand colored (pencil)', 'hand tinted']
        end
      end
    end

    class Leafing < SelectField
      def self.target_tags(f_name)
        {tagline: "with #{str_edit(str: uncamel(f_name), skip:['and'])}", body: "with #{f_name}"}
      end

      class StandardLeafing < Leafing
        def self.targets
          ['goldleaf', 'hand laid goldleaf', 'silverleaf', 'hand laid silverleaf', 'hand laid gold and silver leaf', 'hand laid copperleaf']
        end
      end
    end

    class Remarque < SelectField
      def self.target_tags(f_name)
        {tagline: "with #{str_edit(str: uncamel(f_name), skip:['and'])}", body: "with #{f_name}"}
      end

      class StandardRemarque < Remarque
        def self.targets
          ['remarque', 'hand drawn remarque', 'hand colored remarque', 'hand drawn and colored remarque']
        end
      end
    end
  end

  class FieldSet < Submedium
    def self.attrs
      {kind: 0}
    end

    class ReproductionOnPaper < FieldSet
      def self.targets
        [%W[SelectField Embellishing PaperEmbellishing], %W[SelectField Leafing StandardLeafing], %W[SelectField Remarque StandardRemarque]]
      end
    end

    class ReproductionOnStandard < FieldSet
      def self.targets
        [%W[SelectField Embellishing StandardEmbellishing], %W[SelectField Leafing StandardLeafing]]
      end
    end

    class OriginalOnPaper < FieldSet
      def self.targets
        [%W[SelectField Embellishing PaperEmbellishing], %W[SelectField Leafing StandardLeafing]]
      end
    end
  end
end



# module Assocs
#   module ReproductionOnPaper
#     def self.set
#       {Embellishing: [[:SelectField, :PaperEmbellishing]], Leafing: [[:SelectField, :StandardLeafing]], Remarque: [[:SelectField, :StandardRemarque]]}
#     end
#   end
#
#   module ReproductionOnStandard
#     def self.set
#       {Embellishing: [[:SelectField, :StandardEmbellishing]], Leafing: [[:SelectField, :StandardLeafing]]}
#     end
#   end
#
#   module OriginalOnPaper
#     def self.set
#       {Embellishing: [[:SelectField, :PaperEmbellishing]], Leafing: [[:SelectField, :StandardLeafing]]}
#     end
#   end
# end
