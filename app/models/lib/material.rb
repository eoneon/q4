class Material

  class StandardFlatMatreial
    def self.build_set
      SelectMenu.build_and_assoc(h={field_name: 'standard-flat-material-options', options: [Material::Canvas.build_set, Material::Paper.build_set]})
    end
  end

  class Canvas
    def self.build_set
      SelectField.build_and_assoc(h={field_name: 'canvas-options', options: ['canvas', 'canvas board', 'textured canvas']})
    end
  end

  class Paper
    def self.build_set
      SelectField.build_and_assoc(h={field_name: 'paper-options', options: ['paper', 'deckle edge paper', 'rice paper', 'arches paper', 'sommerset paper', 'mother of pearl paper']})
    end
  end
end
