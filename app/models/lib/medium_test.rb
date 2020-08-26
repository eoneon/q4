class MediumTest
  include Context

  # move these methods to context?
  def self.cascade_merge(klass, set, opt_hsh={})
    opt_hsh = opt_hsh.merge(klass.opt_hsh) if method_exists?(klass, :opt_hsh)
    return set.append(opt_hsh) if !klass.subclasses.any?
    klass.subclasses.each do |target_class|
      cascade_merge(target_class, set, opt_hsh.merge(target_class.opt_hsh))
    end
  end

  def self.option_set_build(options:, prepend_set: [], append_set: [], insert_set: [])
    options = prepend_build(options, prepend_set) if prepend_set.any?
    options = append_build(options, append_set) if append_set.any?
    options = insert_build(options, insert_set) if insert_set.any?
    options.flatten
  end

  def self.prepend_build(options, prepend_set)
    prepend_set.reverse.map {|opt| options.prepend(opt)}.flatten
    options
  end

  def self.append_build(options, append_set)
    append_set.map {|opt| options.append(opt)}.flatten if append_set.any?
    options
  end

  def self.insert_build(options, insert_set)
    insert_set.map {|a| options.insert(a[0], a[1])}.flatten if insert_set.any?
    options
  end

  def self.arg_as_arr(arg)
    arg.class == Array ? arg : [arg]
  end

  # tags methods #################### MediumTest::FSO::OriginalPainting.tags_hsh
  def self.category_set
    ['Original', 'OneOfAKind', 'LimitedEdition']
  end

  def self.medium_category_set
    ['Painting', 'Drawing', 'PrintMedia', 'AcrylicMixedMedia']
  end

  def self.sub_category_set
    ['HandPulled']
  end

  def self.tags_hsh
    tags = %w[sub_category category medium_category medium material].map{|k| [k, 'n/a']}.to_h
    if klass_name == 'PrintMedia'
      tags['category'] = 'PrintMedia'
      tags['medium_category'] = 'PrintMedia'
    elsif klass_name == 'HandPulledPrintMedia'
      tags['sub_category'] = 'HandPulled'
      tags['category'] = 'PrintMedia'
      tags['medium_category'] = 'PrintMedia'
    else
      tag_keys = category_set + medium_category_set + sub_category_set
      tag_keys.each do |k|
        if klass_name.index(k) && category_set.include?(k)
          tags['category'] = k
        elsif klass_name.index(k) && medium_category_set.include?(k)
          tags['medium_category'] = k
        elsif klass_name.index(k) && sub_category_set.include?(k)
          tags['sub_category'] = k
        end
      end
      tags
    end
    tags
  end

  # product hash for: StandardProduct
  # product_name methods
  def self.product_name(tags, set=[])
    tags.each do |k,v|
      next if ['n/a', 'OnPaper', 'Standard', 'PrintMedia'].include?(v)
      set << build_name(k,v) unless set.include?(decamelize(v))
    end
    set.join(' ')
  end

  def self.build_name(k,v)
    if v == 'OneOfAKind'
      'One-of-a-Kind'
    else
      words = cap_words(decamelize(v))
      k == "material" ? "on #{words}" : words
    end
  end

  def self.cap_words(words)
    words.split(' ').map{|word| word.capitalize}.join(' ')
  end
  # tags method
  def self.kv_assign(tags, kv_sets)
    kv_sets.map{|kv| tags[kv[0]] = kv[1]}.first
  end
  # product_options
  def self.build_options(options)
    options.map{|klass| klass.builder}.flatten
  end

  ###################################
  # a = MediumTest.media_sets  a.flatten(1)  aa = a.flatten(1).map{|set| set.last}
  def self.media_sets
    media_groups.map{|h| media_set_builder(h)}.flatten(1)
  end

  def self.media_set_builder(media_set:, material_set:, prepend_set: [], append_set: [], insert_set: [], set: [], tags: {})
    media_set, material_set, prepend_set, append_set, insert_set = [media_set, material_set, prepend_set, append_set, insert_set].map{|arg| arg_as_arr(arg)}
    media_set.product(material_set).each do |option_set|
      kv_assign(tags, [['medium', option_set[0].klass_name], ['material', option_set[1].klass_name]])
      options = option_set_build(options: option_set, prepend_set: prepend_set, append_set: append_set, insert_set: insert_set) #.map{|klass| klass.builder}.flatten
      standard_product(product_name(tags), build_options(options), tags)
    end
    set
  end

  # MediumTest.media_groups
  def self.media_groups
    set=[]
    FSO.subclasses.each do |klass|
      cascade_merge(klass, set, {tags: klass.tags_hsh})
    end
    set
  end

  # FSO #############################

  class FSO < MediumTest

    class OriginalPainting < FSO
      def self.opt_hsh
        {append_set: AppendSet::Standard.set}
      end

      class OnPaper < OriginalPainting
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class Media < OnPaper
          def self.opt_hsh
            {prepend_set: Category::OriginalMedia::Original, media_set: SFO::Painting::OnPaper}
          end
        end
      end

      class OnCanvas < OriginalPainting
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class Media < OnCanvas
          def self.opt_hsh
            {prepend_set: Category::OriginalMedia::Original, media_set: SFO::Painting::Standard}
          end
        end
      end

      class OnStandardMaterial < OriginalPainting
        def self.opt_hsh
          MaterialSet::OnStandardMaterial.opt_hsh
        end

        class Media < OnStandardMaterial
          def self.opt_hsh
            OnCanvas::Media.opt_hsh
          end
        end
      end
    end

    #################################

    class OriginalDrawing < FSO
      def self.opt_hsh
        {append_set: AppendSet::Standard.set}
      end

      class OnPaper < OriginalDrawing
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class Media < OnPaper
          def self.opt_hsh
            {prepend_set: Category::OriginalMedia::Original, media_set: SFO::Drawing::Standard}
          end
        end
      end
    end

    #################################

    class OneOfAKindPrintMedia < FSO
      class OnPaper < OneOfAKindPrintMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Embellishment::Colored, Category::OriginalMedia::OneOfAKind], append_set: AppendSet::WithSubMedia.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Etching, SFO::PrintMedia::Relief, SFO::PrintMedia::MixedMedia::BasicMixedMedia, SFO::PrintMedia::MixedMedia::Monotype]}
            end
          end
        end
      end

      class OnCanvas < OneOfAKindPrintMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Embellishment::Embellished, Category::OriginalMedia::OneOfAKind], append_set: AppendSet::Standard.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Silkscreen, SFO::PrintMedia::MixedMedia::BasicMixedMedia]}
            end
          end
        end
      end
    end

    #################################

    class OneOfAKindAcrylicMixedMedia < FSO
      class OnPaper < OneOfAKindAcrylicMixedMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class Media < OnPaper
          def self.opt_hsh
            {prepend_set: Category::OriginalMedia::OneOfAKind, media_set: SFO::PrintMedia::MixedMedia::AcrylicMixedMedia}
          end
        end
      end

      class OnCanvas < OneOfAKindAcrylicMixedMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class Media < OnCanvas
          def self.opt_hsh
            OnPaper::Media.opt_hsh
          end
        end
      end
    end

    #################################

    class OneOfAKindHandPulledPrintMedia < FSO
      class OnPaper < OneOfAKindHandPulledPrintMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Embellishment::Colored, Category::OriginalMedia::OneOfAKind], append_set: AppendSet::Standard.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: SFO::PrintMedia::Silkscreen}
            end
          end
        end
      end

      class OnCanvas < OneOfAKindHandPulledPrintMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            OneOfAKindPrintMedia::OnCanvas::SubMedia.opt_hsh
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: SFO::PrintMedia::Silkscreen}
            end
          end
        end
      end
    end

    #################################

    class LimitedEditionPrintMedia < FSO
      class OnPaper < LimitedEditionPrintMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Embellishment::Colored, Category::LimitedEdition], append_set: AppendSet::WithSubMediaAndNumbering.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              PrintMedia::OnPaper::SubMedia::Media.opt_hsh
            end
          end
        end
      end

      class OnCanvas < LimitedEditionPrintMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Embellishment::Embellished, Category::LimitedEdition], append_set: AppendSet::Standard.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              PrintMedia::OnCanvas::SubMedia::Media.opt_hsh
            end
          end
        end
      end

      class OnStandardMaterial < LimitedEditionPrintMedia
        def self.opt_hsh
          MaterialSet::OnStandardMaterial.opt_hsh
        end

        class SubMedia < OnStandardMaterial
          def self.opt_hsh
            LimitedEditionPrintMedia::OnCanvas::SubMedia.opt_hsh
          end

          class Media < SubMedia
            def self.opt_hsh
              PrintMedia::OnStandardMaterial::SubMedia::Media.opt_hsh
            end
          end
        end
      end
    end

    #################################

    class LimitedEditionHandPulledPrintMedia < FSO
      class OnPaper < LimitedEditionHandPulledPrintMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Embellishment::Colored, Category::LimitedEdition, SubMedium::RBF::HandPulled], append_set: AppendSet::WithSubMediaAndNumbering.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Lithograph, SFO::PrintMedia::Etching]}
            end
          end
        end
      end

      class OnCanvas < LimitedEditionHandPulledPrintMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::Embellishment::Colored, append_set: AppendSet::WithNumbering.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Silkscreen]}
            end
          end
        end
      end
    end

    #################################

    class HandPulledPrintMedia < FSO
      def self.opt_hsh
        {insert_set: [[1, SubMedium::RBF::HandPulled]]}
      end

      class OnPaper < HandPulledPrintMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Embellishment::Colored], append_set: AppendSet::WithSubMedia.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Lithograph, SFO::PrintMedia::Etching]}
            end
          end
        end
      end

      class OnCanvas < HandPulledPrintMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::Embellishment::Colored, append_set: AppendSet::Standard.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: SFO::PrintMedia::Silkscreen}
            end
          end
        end
      end
    end

    #################################

    class PrintMedia < FSO
      class OnPaper < PrintMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::Embellishment::Colored, append_set: AppendSet::WithSubMedia.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Giclee, SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Lithograph, SFO::PrintMedia::Etching, SFO::PrintMedia::Relief, SFO::PrintMedia::MixedMedia::BasicMixedMedia, SFO::PrintMedia::BasicPrintMedia, SFO::PrintMedia::Poster]}
            end
          end
        end
      end

      class OnCanvas < PrintMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::Embellishment::Embellished}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Giclee, SFO::PrintMedia::Silkscreen, SFO::PrintMedia::MixedMedia::BasicMixedMedia], append_set: AppendSet::Standard.set}
            end
          end
        end
      end

      class OnStandardMaterial < PrintMedia
        def self.opt_hsh
          MaterialSet::OnStandardMaterial.opt_hsh
        end

        class SubMedia < OnStandardMaterial
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::Embellishment::Embellished, append_set: AppendSet::Standard.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Giclee, SFO::PrintMedia::Silkscreen, SFO::PrintMedia::MixedMedia::BasicMixedMedia]}
            end
          end
        end
      end
    end

  end

  # END FSO #########################

  # SFO #############################

  class SFO < MediumTest
    def self.builder
      select_field(field_name, field_kind, options, tags)
    end

    def self.field_name
      decamelize(klass_name).pluralize
    end

    def self.tags
      {'title'=> 'n/a', 'description'=> 'n/a'}
    end

    class Painting < SFO
      class Standard < Painting
        def self.options
          Option.builder(['oil painting', 'acrylic painting', 'mixed media painting', 'painting'], field_kind, tags)
        end

        def self.field_name
          'paint media'
        end
      end

      class OnPaper < Painting
        def self.options
          Option.builder(['watercolor painting', 'pastel painting', 'guache painting', 'sumi ink painting', 'oil painting', 'acrylic painting', 'mixed media painting', 'painting'], field_kind, tags)
        end

        def self.field_name
          'paint media (o/p)'
        end
      end
    end

    class Drawing < SFO
      class Standard < Drawing
        def self.options
          Option.builder(['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing'], field_kind, tags)
        end

        def self.field_name
          'drawing media'
        end
      end
    end

    class PrintMedia < SFO
      class Silkscreen < PrintMedia
        def self.options
          Option.builder(['serigraph', 'silkscreen'], field_kind, tags)
        end
      end

      class Giclee < PrintMedia
        def self.options
          Option.builder(['giclee', 'textured giclee'], field_kind, tags)
        end
      end

      class Lithograph < PrintMedia
        def self.options
          Option.builder(['lithograph', 'offset lithograph', 'original lithograph', 'hand pulled lithograph'], field_kind, tags)
        end
      end

      class Etching < PrintMedia
        def self.options
          Option.builder(['etching', 'etching (black)', 'etching (sepia)', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint'], field_kind, tags)
        end
      end

      class Relief < PrintMedia
        def self.options
          Option.builder(['relief', 'mixed media relief', 'linocut', 'woodblock print', 'block print'], field_kind, tags)
        end
      end

      class MixedMedia < PrintMedia
        class BasicMixedMedia < MixedMedia
          def self.options
            Option.builder(['mixed media'], field_kind, tags)
          end
        end

        class Monotype < MixedMedia
          def self.options
            Option.builder(['monotype'], field_kind, tags)
          end
        end

        class AcrylicMixedMedia < MixedMedia
          def self.options
            Option.builder(['acrylic mixed media'], field_kind, tags)
          end
        end
      end

      class BasicPrintMedia < PrintMedia
        def self.options
          Option.builder(['print', 'fine art print', 'vintage style print'], field_kind, tags)
        end
      end

      class Poster < PrintMedia
        def self.options
          Option.builder(['poster', 'vintage poster', 'concert poster'], field_kind, tags)
        end
      end

    end

    class PhotographMedia < SFO
      class SportsPhotograph < PhotographMedia
        def self.options
          Option.builder(['photograph', 'archival sports photograph'], field_kind, tags)
        end
      end

      class ConcertPhotograph < PhotographMedia
        def self.options
          Option.builder(['photograph', 'concert photograph', 'archival concert photograph'], field_kind, tags)
        end
      end

      class Photograph < PhotographMedia
        def self.options
          Option.builder(['photograph', 'photolithograph', 'archival photograph'], field_kind, tags)
        end
      end

      class SingleExposurePhotograph < PhotographMedia
        def self.options
          Option.builder(['single exposure photograph'], field_kind, tags)
        end
      end

      class PressPhotograph < PhotographMedia
        def self.options
          Option.builder(['vintage press photograph'], field_kind, tags)
        end
      end
    end

    class SericelMedia < SFO
      class Sericel < SericelMedia
        def self.options
          Option.builder(['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline'], field_kind, tags)
        end
      end

      class AnimationCel < SericelMedia
        def self.options
          Option.builder(['production cel', 'production cel and matching drawing', 'production cel and two matching drawings', 'production cel and three matching drawings'], field_kind, tags)
        end
      end
    end
  end

  module MaterialSet
    module OnPaper
      def self.opt_hsh
        {material_set: Material::Paper}
      end
    end

    module OnCanvas
      def self.opt_hsh
        {material_set: [Material::Canvas, Material::WrappedCanvas]}
      end
    end

    module OnStandardMaterial
      def self.opt_hsh
        {material_set: [Material::Wood, Material::WoodBox, Material::Metal, Material::MetalBox, Material::Acrylic]}
      end
    end
  end

  module AppendSet
    module Standard
      def self.set
        [Signature::Standard, Certificate::Standard]
      end
    end

    module WithNumbering
      def self.set
        [Numbering, Signature::Standard, Certificate::Standard]
      end
    end

    module WithSubMedia
      def self.set
        [SubMedium::SMO::Leafing, SubMedium::SFO::Remarque, Signature::Standard, Certificate::Standard]
      end
    end

    module WithSubMediaAndNumbering
      def self.set
        [SubMedium::SMO::Leafing, SubMedium::SFO::Remarque, Numbering, Signature::Standard, Certificate::Standard]
      end
    end
  end
end
