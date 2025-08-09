require 'fastimage'

module Jekyll
  module ImageDimensions
    # Cache for storing image dimensions to avoid repeated file reads
    @@dimensions_cache = {}

    def image_dimensions(image_filename)
      # Return cached result if available
      return @@dimensions_cache[image_filename] if @@dimensions_cache.key?(image_filename)

      # Construct the full path to the image
      site_source = @context.registers[:site].source
      image_path = File.join(site_source, '_config.yml')
      config = YAML.load_file(image_path)
      source_dir = config.dig('picture', 'source') || 'assets/images/src'
      full_path = File.join(site_source, source_dir, image_filename)

      # Get dimensions using FastImage
      dimensions = FastImage.size(full_path)
      
      if dimensions
        width, height = dimensions
        aspect_ratio = width.to_f / height.to_f
        
        result = {
          'width' => width,
          'height' => height,
          'aspect_ratio' => aspect_ratio
        }
        
        # Cache the result
        @@dimensions_cache[image_filename] = result
        result
      else
        # Return default values if image can't be read
        @@dimensions_cache[image_filename] = {
          'width' => 800,
          'height' => 600,
          'aspect_ratio' => 1.33
        }
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::ImageDimensions)
