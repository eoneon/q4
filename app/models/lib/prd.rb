module PRD

  module Painting
    def self.opts
      {
        StandardPainting: [
          RBTN::Category.opts[:Original],
          SFO::Medium.opts[:StandardPainting],
          FGO::Material.opts[:StandardMaterial],
          FG::Authentication.opts[:Authentication]
        ],

        PaintingOnPaper: [
          RBTN::Category.opts[:Original],
          SFO::Medium.opts[:PaintingOnPaper],
          FSO::Material.opts[:Paper],
          FG::Authentication.opts[:Authentication]
        ]
      }
    end
  end

  module Drawing
    def self.opts
      {
        StandardDrawing: [
          RBTN::Category.opts[:Original],
          SFO::Medium.opts[:StandardDrawing],
          FSO::Material.opts[:Paper],
          FG::Authentication.opts[:Authentication]
        ],

        MixedMediaDrawing: [
          RBTN::Category.opts[:Original],
          SFO::Medium.opts[:PaintingOnPaper],
          FSO::Material.opts[:Paper],
          FG::Submedia.opts[:DrawingSubmedia],
          FG::Authentication.opts[:Authentication]
        ]
      }
    end
  end

  module OneOfAKindMixedMedia
    def self.opts
      {
        MixedMediaOnPaper: [
          RBTN::Category.opts[:OneOfAKind],
          FGO::Medium.opts[:OneOfAKindMixedMediaOnPaper],
          FSO::Material.opts[:Paper],
          FG::Submedia.opts[:SubmediaOnPaper],
          FG::Authentication.opts[:Authentication]
        ],

        MixedMediaOnCanvas: [
          RBTN::Category.opts[:OneOfAKind],
          SFO::Medium.opts[:AcrylicMixedMedia],
          FSO::Material.opts[:Canvas],
          FG::Submedia.opts[:StandardSubmedia],
          FG::Authentication.opts[:Authentication]
        ]
      }
    end
  end


  module MixedMedia
    def self.opts
      {
        MixedMedia: [
          #RBTN::Category.opts[:OneOfAKind],       #add LimitedEdition, SingleEdition
          SFO::Medium.opts[:BasicMixedMedia],
          FGO::Material.opts[:StandardMaterial],
          FG::Submedia.opts[:StandardSubmedia],
          FG::Authentication.opts[:Authentication]
        ]
      }
    end
  end

  module PrintMedia
    def self.opts
      {
        StandardPrint: [
          FGO::Medium.opts[:StandardPrint],
          FGO::Material.opts[:StandardMaterial],
          FG::Submedia.opts[:StandardSubmedia],
          FG::Authentication.opts[:Authentication]
        ],

        PrintOnPaper: [
          FGO::Medium.opts[:PrintOnPaper],
          FSO::Material.opts[:Paper],
          FG::Submedia.opts[:SubmediaOnPaper],
          FG::Authentication.opts[:Authentication]
        ]
      }
    end
  end

  module HandPulledPrint
    def self.opts
      {
        PrintOnPaper: [
          FGO::Medium.opts[:HandPulledPrintOnPaper],
          FSO::Material.opts[:Paper],
          FG::Submedia.opts[:SubmediaOnPaper],
          FG::Authentication.opts[:Authentication]
        ],

        PrintOnCanvas: [
          FSO::Medium.opts[:HandPulledSilkscreen],
          FGO::Material.opts[:Canvas],
          FG::Submedia.opts[:StandardSubmedia],
          FG::Authentication.opts[:Authentication]
        ]
      }
    end
  end

end
