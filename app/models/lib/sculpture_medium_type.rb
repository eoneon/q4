class SculptureMediumType
  include Context
  #SculptureMediumType.build_type_group
  class Glass < SculptureMediumType
    def self.set
      ['glass']
    end
  end
end
  # class Glass < Material
  #   class OptionValue < Glass
  #     def self.option
  #       ['glass']
  #     end
  #   end
  # end
  #
  # class Ceramic < Material
  #   class OptionValue < Ceramic
  #     def self.option
  #       ['ceramic']
  #     end
  #   end
  # end
  #
  # class Bronze < Material
  #   class OptionValue < Bronze
  #     def self.option
  #       ['bronze']
  #     end
  #   end
  # end
  #
  # class Synthetic < Material
  #   class OptionValue < Synthetic
  #     def self.option
  #       ['acrylic', 'lucite', 'mixed media']
  #     end
  #   end
  # end
  #
  # class Stone < Material
  #   class OptionValue < Stone
  #     def self.option
  #       ['pewter']
  #     end
  #   end
  # end
