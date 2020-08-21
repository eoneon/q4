class OriginalPainting < ProductGroup
  class OriginalPaintingStandard < OriginalPainting
    def self.option_hsh
      {prepend_set: Category::OriginalMedia::Original, media_set: SFO::PaintingMedia::StandardPainting, material_set: Material::StandardMaterial.options, append_set: [Signature::Standard, Certificate::Standard]}
    end
  end

  class OriginalPaintingPaperOnly < OriginalPainting
    def self.option_hsh
      {prepend_set: Category::OriginalMedia::Original, media_set: SFO::PaintingMedia::PaintingPaperOnly, material_set: Material::Paper, append_set: [Signature::Standard, Certificate::Standard]}
    end
  end
end

class OriginalDrawing < ProductGroup
  class DrawingStandard < OriginalDrawing
    def self.option_hsh
      {prepend_set: Category::OriginalMedia::Original, media_set: SFO::DrawingMedia::StandardDrawing, material_set: Material::Paper, append_set: [Signature::Standard, Certificate::Standard]}
    end
  end

  class OriginalMixedMediaDrawing < OriginalDrawing
    def self.option_hsh
      {prepend_set: Category::OriginalMedia::Original, media_set: SFO::DrawingMedia::MixedMediaDrawing, material_set: Material::Paper, append_set: [SubMedium::SMO::Leafing, Signature::Standard, Certificate::Standard]}
    end
  end
end



def self.builder(media_set:, material_set:, prepend_set: [], append_set: [], insert_set: [], set: [])
  media_set, material_set, prepend_set, append_set, insert_set = [media_set, material_set, prepend_set, append_set, insert_set].map{|arg| Medium.arg_as_arr(arg)}
  media_set.product(material_set).each do |option_set|
    set << Medium.option_set_build(options: option_set, prepend_set: prepend_set, append_set: append_set, insert_set: insert_set:)
  end
end

def option_set_build(options:, prepend_set: [], append_set: [], insert_set: [])
  options = prepend_build(options, prepend_set)
  options = append_build(options, append_set)
  options = insert_build(options, insert_set)
  options.flatten
end

def prepend_build(options, prepend_set)
  return options if prepend_set.empty?
  prepend_set.reverse.map {|opt| options.prepend(opt)}.flatten
  options
end

def append_build(options, append_set)
  return options if append_set.empty?
  append_set.map {|opt| options.append(opt)}.flatten if append_set.any?
  options
end

def insert_build(options, insert_set)
  return options if insert_set.empty?
  insert_set.map {|a| options.insert(a[0], a[1])}.flatten if insert_set.any?
end

def arg_as_arr(arg)
  arg.class == Array ? arg : [arg]
end

######################################

class SFO < Medium
  class Painting < SFO
    class Standard < Painting
      def self.options
        OptionSet.builder(['painting', 'oil', 'acrylic', 'mixed media'], field_kind, tags)
      end
    end

    class OnPaperOnly < Painting
      def self.options
        OptionSet.builder(['watercolor', 'pastel', 'guache', 'sumi ink'], field_kind, tags)
      end
    end

    module OptionSet
      def self.builder(set, field_kind, tags)
        Option.builder(set.map {|opt_name| Medium.build_name([opt_name, 'painting'])}, field_kind, tags)
      end
    end
  end

  class Drawing < SFO
    class Standard< DrawingMedia
      def self.options
        Option.builder(['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing'], field_kind, tags)
      end
    end
  end

  class PrintsMedia < SFO
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
      class Basic < MixedMedia
        def self.options
          Option.builder(['mixed media'], field_kind, tags)
        end
      end

      class Standard < MixedMedia
        def self.options
          Option.builder(['mixed media acrylic', 'monotype'], field_kind, tags)
        end
      end
    end

    class Basic < PrintMedia
      def self.options
        Option.builder(['print', 'fine art print', 'vintage style print'], field_kind, tags)
      end
    end

    class Poster < PrintMedia
      def self.options
        Option.builder(['poster', 'vintage poster', 'concert poster'], field_kind, tags)
      end
    end

    class Sericel < PrintsMedia
      def self.options
        Option.builder(['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline'], field_kind, tags)
      end
    end

    class Photograph < PrintsMedia
      def self.options
        Option.builder(['photograph', 'photolithograph', 'archival photograph'], field_kind, tags)
      end
    end
  end
end

######################################

######################################
# Prints::OnPaper
class Prints < FSO
  class OnPaper < Prints
    def self.opt_hsh
      {material_set: Material::Paper}
    end

    class Mixed < OnPaper
      def self.opt_hsh
        {prepend_set: SubMedium::SFO::Embellishment::Colored, append_set: [SubMedium::SMO::Leafing, SubMedium::SFO::Remarque]}
      end

      class Media < Mixed
        def self.opt_hsh
          {media_set: [SFO::PrintMedia::Giclee, SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Lithograph, SFO::PrintMedia::Etching, SFO::PrintMedia::Relief, SFO::PrintMedia::MixedMedia::Basic, SFO::PrintMedia::Basic, SFO::PrintMedia::Poster]}
        end
      end
    end

    class HandPulled < OnPaper
      def self.opt_hsh
        {insert_set: [[1, SubMedium::RBF::HandPulled]]}
      end

      class Media < HandPulled
        def self.opt_hsh
          {prepend_set: SubMedium::SFO::Embellishment::Colored, media_set: [SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Lithograph, SFO::PrintMedia::Etching]}
        end
      end
    end
  end

  class OnCanvas < Prints
    def self.opt_hsh
      {material_set: [Material::Canvas, Material::WrappedCanvas]}
    end

    class Mixed < OnCanvas
      def self.opt_hsh
        {prepend_set: SubMedium::SFO::Embellishment::Embellished}
      end

      class Media < Mixed
        def self.opt_hsh
          {media_set: [SFO::PrintMedia::Giclee, SFO::PrintMedia::Silkscreen, SFO::PrintMedia::MixedMedia::Basic]}
        end
      end
    end

    class HandPulled < OnCanvas
      def self.opt_hsh
        {insert_set: [[1, SubMedium::RBF::HandPulled]]}
      end

      class Media < HandPulled
        def self.opt_hsh
          {media_set: SFO::PrintMedia::Silkscreen}
        end
      end
    end
  end

  class OnStandardMaterial < Prints
    def self.opt_hsh
      {material_set: [Material::Wood, Material::WoodBox, Material::Metal, Material::MetalBox, Material::Acrylic]}
    end

    class Mixed < OnCanvas
      def self.opt_hsh
        {prepend_set: SubMedium::SFO::Embellishment::Embellished}
      end

      class Media < Mixed
        def self.opt_hsh
          {media_set: [SFO::PrintMedia::Giclee, SFO::PrintMedia::Silkscreen, SFO::PrintMedia::MixedMedia::Basic]}
        end
      end
    end
  end
end

class LimitedEditionPrints < FSO
end

class OneOfAKindMixedMedia < FSO
  class OnPaper < Prints
    def self.opt_hsh
      {material_set: Material::Paper}
    end

    class Mixed < OnPaper
      def self.opt_hsh
        {prepend_set: SubMedium::SFO::Embellishment::Colored, append_set: [SubMedium::SMO::Leafing]}
      end

      class Media < Mixed
        def self.opt_hsh
          {media_set: [SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Etching, SFO::PrintMedia::Relief]}
        end
      end
    end

    class HandPulled < OnPaper
      def self.opt_hsh
        {insert_set: [[1, SubMedium::RBF::HandPulled]]}
      end

      class Media < HandPulled
        def self.opt_hsh
          {prepend_set: SubMedium::SFO::Embellishment::Colored, media_set: [SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Etching]}
        end
      end
    end
  end

  class OnCanvas < Prints
    def self.opt_hsh
      {material_set: [Material::Canvas, Material::WrappedCanvas]}
    end

    class Mixed < OnCanvas
      def self.opt_hsh
        {prepend_set: SubMedium::SFO::Embellishment::Embellished}
      end

      class Media < Mixed
        def self.opt_hsh
          {media_set: [SFO::PrintMedia::Silkscreen]}
        end
      end
    end

    class HandPulled < OnCanvas
      def self.opt_hsh
        {insert_set: [[1, SubMedium::RBF::HandPulled]]}
      end

      class Media < HandPulled
        def self.opt_hsh
          {media_set: SFO::PrintMedia::Silkscreen}
        end
      end
    end
  end
end

class Painting < FSO
end

class Drawing < FSO
end

######################################
#for each set to be duplicated: assign to instance variable: [@print, ...]
######################################

def self.option_sets
  set=[]
  subclasses.each do |klass|
    set << builder(cascade_merge(klass))
  end
  set
end

def cascade_merge(klass, opt_hsh={}) #Prints
  return opt_hsh if klass.subclasses.none? || method_exists?(klass, :opt_hsh)
  klass.subclasses.each do |target_class| #OnPaper
    opt_hsh.merge(target_class.opt_hsh)  #OnPaper.opt_hsh if target_class.any?
    opt_hsh_merge(target_class, opt_hsh)
  end
end

######################################

######################################

class PrintOnPaper < FSO
  def self.option_sets
    set=[]
    subclasses.each do |klass|
      FieldSetOption.builder(media_set: klass.media_set, material_set: Material::Paper).each do |option_set|
        set << option_set_build(options: option_set, prepend_set: SubMedium::SFO::Embellishment::Colored, append_set: [SubMedium::SMO::Leafing, SubMedium::SFO::Remarque])
      end
    end
    set
  end

  #after signature insert-> Numbering
  class MixedPrintOnPaper < FSO
    def self.set
      [
        [0,
          SFO::SilkscreenMedia::Serigraph,
          SFO::SilkscreenMedia::Silkscreen
        ],

        [1,
          SFO::Giclee,
          SFO::MixedMedia::StandardMixedMedia,
          SFO::PrintMedia::BasicPrint
        ]
      ]
    end
  end

  class MixedMediaOnPaper < PrintsOnPaper
    def self.media_set
      [SFO::MixedMedia::Monotype, SFO::MixedMedia::AcrylicMixedMedia]
    end
  end

  class MixedMediaPrintOnPaper < PrintsOnPaper
    def self.media_set
      [SFO::EtchingMedia::MixedMediaEtching, SFO::ReliefMedia::MixedMediaRelief]
    end
  end

  class MixedPrintOnPaperOnly < FSO
    def self.media_set
      [SFO::LithographMedia::Lithograph, SFO::EtchingMedia::Etching, SFO::ReliefMedia::Relief]
    end
  end
end

class PrintOnCanvas < FSO
  def self.option_sets
    set=[]
    subclasses.each do |klass|
      FieldSetOption.builder(media_set: klass.media_set, material_set: [Material::Canvas, Material::WrappedCanvas]).each do |option_set|
        set << option_set_build(options: option_set, prepend_set: SubMedium::SFO::Embellishment::Embellished)
      end
    end
    set
  end

  class MixedMediaOnCanvas < FSO
    def self.media_set
      [SFO::MixedMedia::AcrylicMixedMedia]
    end
  end

  class MixedPrintOnCanvas < FSO
    def self.media_set
      MixedPrintOnPaper.media_set
    end
  end
end

class PrintOnStandardMaterial < FSO
  class StandardPrint < PrintOnStandardMaterial
    def self.media_group
      LimitedEditionPrint.media_group + BasicPrintMedia.subclasses
    end

    def self.option_sets
      set=[]
      FieldSetOption.builder(media_set: media_group.map{|klass| klass.option_sets}.flatten(1), material_set: [Material::Wood, Material::WoodBox, Material::Metal, Material::MetalBox, Material::Acrylic]).each do |option_set|
        set << option_set_build(options: option_set, prepend_set: SubMedium::SFO::Embellishment::Embellished)
      end
      set
    end
  end

  class MixedPrintOnStandardMaterial < FSO
    def self.media_set
      MixedPrintOnPaper.media_set
    end

    def self.option_sets
      FieldSetOption.builder(media_set: media_set, material_set: [Material::Wood, Material::WoodBox, Material::Metal, Material::MetalBox, Material::Acrylic], prepend_set: SubMedium::SFO::Embellishment::Embellished, append_set: SubMedium::SFO::Remarque)
    end
  end

  class MixedPrintOnStandardMaterial < FSO
    def self.media_set
      MixedPrintOnPaper.media_set
    end

    def self.option_sets
      FieldSetOption.builder(media_set: media_set, material_set: [Material::Wood, Material::WoodBox, Material::Metal, Material::MetalBox, Material::Acrylic], prepend_set: SubMedium::SFO::Embellishment::Embellished, append_set: SubMedium::SFO::Remarque)
    end
  end

  class BasicPrintOnStandardMaterial < BasicPrintMedia
    def self.media_set
      [SFO::PrintMedia::BasicPrint]
    end

    def self.option_sets
      FieldSetOption.builder(media_set: media_set, material_set: [Material::Wood, Material::WoodBox, Material::Metal, Material::MetalBox, Material::Acrylic], append_set: SubMedium::SFO::Remarque)
    end
  end
end

class HandPulledPrints < FSO
  class HandPulledPrintOnPaper < FSO
    def self.media_set
      MixedPrintOnPaper.media_set(0)
    end

    def self.option_sets
      #media_materials_sets = FieldSetOption.builder(media_set: media_set, material_set: Material::Paper, prepend_set: [SubMedium::SFO::Embellishment::Colored, SubMedium::RBF::HandPulled], append_set: [SubMedium::SMO::Leafing, SubMedium::SFO::Remarque])
      media_materials_sets = FieldSetOption.builder(media_set: media_set, material_set: Material::Paper)
      media_materials_sets.map{|option_set| option_set_build(options: option_set, prepend_set: [SubMedium::SFO::Embellishment::Colored, SubMedium::RBF::HandPulled], append_set: [SubMedium::SMO::Leafing, SubMedium::SFO::Remarque])}
    end
  end

  class HandPulledPrintOnCanvas < FSO
    def self.media_set
      MixedPrintOnPaper.media_set(0)
    end

    def self.option_sets
      #media_materials_sets = FieldSetOption.builder(media_set: media_set, material_set: [Material::Canvas, Material::WrappedCanvas], prepend_set: [SubMedium::SFO::Embellishment::Embellished, SubMedium::RBF::HandPulled])
      media_materials_sets = FieldSetOption.builder(media_set: media_set, material_set: [Material::Canvas, Material::WrappedCanvas], prepend_set: [SubMedium::SFO::Embellishment::Embellished, SubMedium::RBF::HandPulled])
      media_materials_sets.map{|option_set| option_set_build(options: option_set, prepend_set: [SubMedium::SFO::Embellishment::Colored, SubMedium::RBF::HandPulled])}
    end
  end
end
# def self.option_sets
#   media_materials_sets = FieldSetOption.builder(media_set: media_set, material_set: Material::Paper)
#   media_materials_sets.map{|option_set| option_set_build(options: option_set, prepend_set: [SubMedium::SFO::Embellishment::Colored, SubMedium::RBF::HandPulled], append_set: [SubMedium::SMO::Leafing, SubMedium::SFO::Remarque])}
# end
