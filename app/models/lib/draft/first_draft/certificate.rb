class Certificate
  include Context

  def self.tags
    tags_hsh(0,-1)
  end

  def self.field_name
    "#{field_name} coa"
  end

  class Standard < Certificate
    def self.builder
      select_field(field_name, field_kind, SFO::Standard.builder, tags)
    end
  end

  class PeterMax < Certificate
    def self.builder
      select_field(field_name, field_kind, Option.builder(['LOA', 'COA', 'COA from Peter Max Studios']), tags)
    end
  end

  class PsaDna < Certificate
    def self.builder
      select_field(field_name, field_kind, Option.builder(['LOA', 'COA', 'PSA/DNA']), tags)
    end
  end

  class Britto < Certificate
    def self.builder
      select_field(field_name, field_kind, Option.builder(['LOA', 'COA', 'stamped inverso']), tags)
    end
  end

  class SFO < Certificate
    class Standard < SFO
      def self.builder
        Option.builder(['LOA', 'COA'], field_kind, tags)
      end
    end
  end

  #Certificate::Standard.builder Certificate::Animation.builder Certificate::Animation::AnimationSeal.builder
  # class Animation < Certificate
  #   def self.builder
  #     select_menu(field_name, field_kind, FieldSetOption.builder, tags)
  #   end
  #
  #   class AnimationSeal < Animation
  #     def self.builder
  #       select_field(field_name, field_kind, Option.builder(['Warner Bros.', 'Looney Tunes', 'Hanna Barbera']), tags)
  #     end
  #   end
  #
  #   class SportsSeal < Animation
  #     def self.builder
  #       select_field(field_name, field_kind, Option.builder(['NFL', 'NBA', 'MLB', 'NHL']), tags)
  #     end
  #   end
  #
  #   class AnimationCertificate < Animation
  #     def self.builder
  #       select_field(field_name, field_kind, Option.builder(['LOA', 'COA', 'COA from Linda Jones Enterprises']), tags)
  #     end
  #   end
  #
  #   module FieldSetOption
  #     def self.builder
  #       set=[]
  #       option_sets.each do |option_set|
  #         set << FieldSet.builder(f={field_name: Certificate.arr_to_text(option_set.map(&:field_name)), kind: field_kind, options: option_set})
  #       end
  #       set.flatten
  #     end
  #     #sets of select_fields [select_field, select_field, select_field]
  #     def self.option_sets
  #       [[AnimationSeal.builder, SportsSeal.builder, AnimationCertificate.builder], [AnimationSeal.builder, AnimationCertificate.builder], [SportsSeal.builder, AnimationCertificate.builder], [SportsSeal.builder, AnimationSeal.builder], [AnimationSeal.builder], [AnimationCertificate.builder]]
  #     end
  #   end

  # end

end
