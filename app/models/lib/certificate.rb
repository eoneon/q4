class Certificate
  include Context

  def self.field_name
    "#{field_class_name} COA"
  end

  class Standard < Certificate
    def self.builder
      select_field(field_name, field_kind, Option.builder(['COA', 'LOA']), search_hsh)
    end
  end

  class PeterMax < Certificate
    def self.builder
      select_field(field_name, field_kind, Option.builder(['COA', 'LOA', 'COA from Peter Max Studios']), search_hsh)
    end
  end

  class PsaDna < Certificate
    def self.builder
      select_field(field_name, field_kind, Option.builder(['COA', 'LOA', 'PSA/DNA']), search_hsh)
    end
  end

  class Britto < Certificate
    def self.builder
      select_field(field_name, field_kind, Option.builder(['COA', 'LOA', 'stamped inverso']), search_hsh)
    end
  end

  #Certificate::Standard.builder Certificate::Animation.builder Certificate::Animation::AnimationSeal.builder
  class Animation < Certificate
    def self.builder
      select_menu(field_name, field_kind, FieldSetOption.builder, search_hsh)
    end

    class AnimationSeal < Animation
      def self.builder
        select_field(field_class_name, field_kind, Option.builder(['Warner Bros.', 'Looney Tunes', 'Hanna Barbera']), search_hsh)
      end
    end

    class SportsSeal < Animation
      def self.builder
        select_field(field_class_name, field_kind, Option.builder(['NFL', 'NBA', 'MLB', 'NHL']), search_hsh)
      end
    end

    class AnimationCertificate < Animation
      def self.builder
        select_field(field_class_name, field_kind, Option.builder(['COA', 'LOA', 'COA from Linda Jones Enterprises']), search_hsh)
      end
    end

    module FieldSetOption
      def self.builder
        set=[]
        option_sets.each do |option_set|
          set << FieldSet.builder(f={field_name: Certificate.arr_to_text(option_set.map(&:field_name)), kind: field_kind, options: option_set})
        end
        set.flatten
      end
      #sets of select_fields [select_field, select_field, select_field]
      def self.option_sets
        [[AnimationSeal.builder, SportsSeal.builder, AnimationCertificate.builder], [AnimationSeal.builder, AnimationCertificate.builder], [SportsSeal.builder, AnimationCertificate.builder], [SportsSeal.builder, AnimationSeal.builder], [AnimationSeal.builder], [AnimationCertificate.builder]]
      end
    end

  end

end
