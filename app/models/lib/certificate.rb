class Certificate
  include Context

  class Standard < Certificate
    def self.builder
      select_field_group(field_class_name, Option.builder(['COA', 'LOA']))
    end
  end

  class PeterMax < Certificate
    def self.builder
      select_field_group(field_class_name, Option.builder(['COA', 'LOA', 'COA from Peter Max Studios']))
    end
  end

  class PsaDna < Certificate
    def self.builder
      select_field_group(field_class_name, Option.builder(['COA', 'LOA', 'PSA/DNA']))
    end
  end

  class Britto < Certificate
    def self.builder
      select_field_group(field_class_name, Option.builder(['COA', 'LOA', 'stamped inverso']))
    end
  end

  #Certificate::Animation.builder
  class Animation < Certificate
    def self.builder
      select_menu_group(field_class_name, FieldGroup.builder.flatten)
    end

    class AnimationSeal < Certificate
      def self.builder
        select_field_group(field_class_name, Option.builder(['Warner Bros.', 'Looney Tunes', 'Hanna Barbera']))
      end
    end

    class SportsSeal < Certificate
      def self.builder
        select_field_group(field_class_name, Option.builder(['NFL', 'NBA', 'MLB', 'NHL']))
      end
    end

    class AnimationCertificate < Certificate
      def self.builder
        select_field_group(field_class_name, Option.builder(['COA', 'LOA', 'COA from Linda Jones Enterprises']))
      end
    end

    module FieldGroup
      def self.builder
        option_sets.each do |options|
          FieldSet.builder(f={field_name: Certificate.arr_to_text(options.map(&:field_name)), options: options})
        end
      end

      def self.option_sets
        [[AnimationSeal.builder, SportsSeal.builder, AnimationCertificate.builder], [AnimationSeal.builder, AnimationCertificate.builder], [SportsSeal.builder, AnimationCertificate.builder], [SportsSeal.builder, AnimationSeal.builder], [AnimationSeal.builder], [AnimationCertificate.builder]]
      end
    end

  end

end
