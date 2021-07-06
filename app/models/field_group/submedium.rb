class Submedium
  include ClassContext
  include FieldSeed
  include Hashable

  def self.attrs
    {kind: 2, type: 1, f_name: -1}
  end

  class SelectField < Submedium
    class Embellishing < SelectField
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
      class StandardLeafing < Leafing
        def self.targets
          ['gold leaf', 'hand laid gold leaf', 'silver leaf', 'hand laid silver leaf', 'hand laid gold and silver leaf', 'hand laid copper leaf']
        end
      end
    end

    class Remarque < SelectField
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
