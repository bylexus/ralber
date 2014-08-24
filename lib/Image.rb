require 'rubygems'
require 'bundler/setup'

require 'json'
require 'fastimage'
require 'fastimage_resize'

##
# Represents an image with its metadata. Performs also converting
# functions like thumbs etc.
class Image
    attr :path
    attr_reader :title, :type, :description, :width, :height

    def initialize(path)
        raise StandardError, "File does not exits" if not File.exists?(path)
        @path = File.expand_path(path)
        @image_info = self.get_image_info
    end

    def title
        @image_info['title']
    end
    def type
        @image_info['type']
    end
    def description
        @image_info['description']
    end
    def width
        @image_info['width']
    end
    def height
        @image_info['height']
    end

    ##
    # creates the initial image.json file, extracting the metadata
    # if possible. If the image is not recognized, an exception is raised.
    def create
        open(self.json_path,'w') do |f|
            f.write(JSON.generate(@image_info))
        end
    end

    def json_path
        File.expand_path(@path)+'.json'
    end

    ##
    # reads image metainfos from the image file and, if present,
    # from the image.json file.
    def get_image_info
        info = {
            "title" => File.basename(@path),
            "type" => self.image_type,
            "description" => '',
            "width" => self.image_dimensions[:width],
            "height" => self.image_dimensions[:height]
        }
        if File.exists?(json_path)
            begin
                data = JSON.parse(File.read(json_path))
                if data.respond_to?(:key?)
                    (info['title'] = data['title']) if data.key?('title')
                    (info['description'] = data['description']) if data.key?('description')
                end
            rescue
            end
        end
        return info
    end

    def image_type
        type = FastImage.type(@path)
        raise StandardError, "Unknown image type" if not type
        return type
    end

    def image_dimensions
        dim = FastImage.size(@path)
        { :width => dim[0],:height => dim[1] }
    end

    def create_resized_image(output_filename, width = 0, height = 0)
        FastImage.resize(@path,width,height,:outfile => output_filename)
    end
end
