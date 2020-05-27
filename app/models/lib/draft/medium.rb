class Medium
  include Context
  #Medium::OriginalCategory::DrawingMedia::Drawing.builder
  #Medium::OriginalCategory::DrawingMedia::MixedMediaDrawing.builder

  #compound media ##############################################################
  class OriginalCategory < Medium

    def self.category_radio_button
      Category::OriginalMedia::Original.builder
    end

    class PaintMedia < OriginalCategory
      class Painting < PaintMedia
        def self.builder
          select_field = select_field('paint-media', options, search_hsh)
          select_menu = Material::StandardMaterial.builder
          select_menu(field_class_name, [category_radio_button,select_field,select_menu], search_hsh)
        end

        def self.options
          OptionSet.builder(['painting', 'oil', 'acrylic', 'mixed media'], tags_hsh(0,1))
        end
      end

      class PaintingOnPaper < PaintMedia
        def self.builder
          select_field = select_field('paint-media (paper only)', options, search_hsh)
          select_menu = Material::Paper.builder
          select_menu(field_class_name, [category_radio_button,select_field,select_menu], search_hsh)
        end

        def self.options
          OptionSet.builder(['watercolor', 'pastel', 'guache', 'sumi ink'], tags_hsh(0,1))
        end
      end

      module OptionSet
        def self.builder(set, tags)
          Option.builder(set.map {|opt_name| Medium.build_name([opt_name, 'painting'])}, tags)
        end
      end

    end

    class DrawingMedia < OriginalCategory
      def self.material_select_menu
        Material::Paper.builder
      end

      class Drawing < DrawingMedia
        def self.builder
          select_field = select_field(field_class_name, options, search_hsh)
          #select_menu = Material::Paper.builder #
          select_menu(field_class_name, [category_radio_button, select_field, material_select_menu], search_hsh)
        end

        def self.options
          Option.builder(['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing'], tags_hsh(0,1))
        end
      end

      class MixedMediaDrawing < DrawingMedia
        def self.builder
          select_field = select_field(field_class_name, options, search_hsh)
          #select_menu = Material::Paper.builder
          select_menu(field_class_name, [Embellishment::Colored.builder, category_radio_button, select_field, material_select_menu, Leafing.builder], search_hsh)
        end

        def self.options
          Option.builder(['pen and ink drawing', 'pencil drawing'], tags_hsh(0,1))
        end
      end
    end

  end #end of OriginalCategory

  class OriginalProductionCategory < Medium

    def self.category_radio_button
      Category::OriginalMedia::OriginalProduction.builder
    end

    class BasicDrawing < OriginalProductionCategory
      def self.builder
        select_field = select_field(field_class_name, options, search_hsh)
        select_menu = Material::AnimationPaper.builder
        select_menu(field_class_name, [category_radio_button,select_field,select_menu], search_hsh)
      end

      def self.options
        Option.builder(['drawing'], search_hsh)
      end
    end

    class BasicSericel < OriginalProductionCategory
      def self.builder
        select_field = select_field(field_class_name, options, search_hsh)
        select_menu = Material::Sericel.builder
        select_menu(field_class_name, [category_radio_button,select_field,select_menu], search_hsh)
      end

      def self.options
        Option.builder(['sericel', 'hand painted sericel'], search_hsh)
      end
    end
  end #end of OriginalProductionCategory

  class SericelMedia < Medium
    class Sericel < SericelMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline'], tags_hsh(0,1))
      end
    end

    class BasicSericel < SericelMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['sericel', 'hand painted sericel'], tags_hsh(0,1))
      end
    end
  end

  ##############################################################################

  class Embellishment < Medium
    def self.tags
      tags_hsh(-2,-1)
    end

    class Embellished < Embellishment
      def self.builder
        select_field(field_class_name, options, tags)
      end

      def self.options
        Option.builder(['hand embellished', 'hand painted', 'artist embellished'], tags)
      end
    end

    class Colored < Embellishment
      def self.builder
        select_field(field_class_name, options, tags)
      end

      def self.options
        Option.builder(['hand colored', 'hand watercolored', 'hand colored (pencil)', 'hand tinted'], tags)
      end
    end
  end
  #Medium::Leafing.tags
  class Leafing < Medium
    def self.tags
      tags_hsh(-1,-1)
    end

    def self.builder
      select_menu(field_class_name, [GoldLeaf.builder, SilverLeaf.builder], search_hsh)
    end

    class GoldLeaf < Leafing
      def self.tags
        tags_hsh(-2,-1)
      end

      def self.builder
        select_field(field_class_name, options, tags)
      end

      def self.options
        Option.builder(['goldleaf', 'hand laid goldleaf'], tags)
      end
    end

    class SilverLeaf < Leafing
      def self.tags
        tags_hsh(-2,-1)
      end

      def self.builder
        select_field(field_class_name, options, tags)
      end

      def self.options
        Option.builder(['silverleaf', 'hand laid silverleaf'], tags)
      end
    end
  end

  class Remarque < Medium
    def self.tags
      tags_hsh(-1,-1)
    end

    def self.builder
      select_field(field_class_name, options, tags)
    end

    def self.options
      Option.builder(['remarque', 'hand drawn remarque', 'hand colored remarque', 'hand drawn and colored remarque'], tags)
    end
  end

  class HandPulled < Medium
    def self.tags
      tags_hsh(-1,-1)
    end

    def self.builder
      radio_button(field_class_name, tags)
    end
  end

end
