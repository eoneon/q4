class Dimension
  include Fieldable

  def dimension_hsh(h, k, tags)
    dimensions.each do |kind, keys|
      if scoped_tags = scoped_dimensions(keys, tags)
        measurements = format_measurements(scoped_dimensions)
        param_merge(params: h, dig_set: dig_set(k: k+'s', v: scoped_tags, dig_keys: [k,kind]))
        param_merge(params: h, dig_set: dig_set(k: 'measurements', v: measurements, dig_keys: [k,kind]))
        if material_tags = scoped_tags['material']
          param_merge(params: h, dig_set: dig_set(k: 'size', v: size_case(material_tags), dig_keys: [k,kind]))
        end
      end
    end
    h
  end

  def format_measurements(dimensions)
    dimensions.map{|i| i+"\""}.join(' x ')
  end

  def scoped_dimensions(dimension_set, tags)
    dims = dimension_set.map{|k| [k, tags[k]]}.to_h.reject{|k,v| v.blank?}
    dims unless dims.empty?
  end

  def size_case(material_tags)
    case
      when material_tags.keys[0..1] == %w[width height]; material_tags.values[0..1].inject{|product, i| product * i.to_i}
      when material_tags.keys[0] == 'diameter'; material_tags.values[0] * material_tags.values[0]
    end
  end

  def dimensions
    {'material'=> %w[diameter width height depth], 'mounting'=> %w[mounting_width mounting_height]}
  end
end
