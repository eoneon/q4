class ArtistField
  include Context

  def self.tags
    h={kind: 'artist'}
  end

  def self.field_name
    decamelize(klass_name, '-')
  end

  def self.builder
    field_set(field_name, [ArtistName, YearsActive, ArtistId].map{|klass| klass.builder}, tags)
  end

  class ArtistName < ArtistField
    def self.builder
      field_set(field_name, options, tags)
    end

    def self.options
      %w[first_name middle_name last_name].map{|name| text_field(name, tags)}
    end
  end

  class YearsActive < ArtistField
    def self.builder
      field_set(field_name, options, tags)
    end

    def self.options
      %w[yob dob].map{|name| text_field(name, tags)}
    end
  end

  class ArtistId < ArtistField
    def self.builder
      number_field(field_name, tags)
    end
  end

end
