require 'rubygems'
require 'bundler/setup'

require 'json'
require 'rmagick'
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
        @image_info = get_new_info
        meta = self.image_metadata
        type = meta[:type]
        raise StandardError, "Unknown image type" if not type
        @image_info['type'] = type
        @image_info['width'] = meta[:width]
        @image_info['height'] = meta[:height]

        self.write_imageinfo
    end

    def write_imageinfo
        open(self.json_path,'w') do |f|
            f.write(JSON.pretty_generate(@image_info))
        end
    end

    def json_path
        File.expand_path(@path)+'.json'
    end

    def get_new_info
        {
            "title" => File.basename(@path),
            "type" => nil,
            "description" => '',
            "width" => 0,
            "height" => 0
        }
    end

    ##
    # reads image metainfos from the image file and, if present,
    # from the image.json file.
    def get_image_info
        info = get_new_info
        if File.exists?(json_path)
            begin
                data = JSON.parse(File.read(json_path))
                if data.respond_to?(:key?)
                    (info['title'] = data['title']) if data.key?('title')
                    (info['description'] = data['description']) if data.key?('description')
                    (info['type'] = data['type'].to_sym) if data.key?('type')
                    (info['width'] = data['width']) if data.key?('width')
                    (info['height'] = data['height']) if data.key?('height')
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

    def image_metadata
        img = Magick::Image::read(@path).first
        {
            :width => img.columns,
            :height => img.rows,
            :type => self.map_type(img.format)
        }
    end

    def map_type(imagickType)
        case imagickType
            when 'JPEG' then :jpeg
            when 'PNG' then :png
            when 'GIF' then :gif
            else nil
        end
    end

    def create_resized_image(output_filename, geometry_string)
        img = Magick::Image::read(@path).first
        img.change_geometry!(geometry_string) { |cols, rows, manipImg|
            img.resize!(cols, rows)
        }
        img.write(output_filename)
    end

    def create_resized_version(type, geometry_string, output_dir)
        name = self.get_resized_name(@path, type)
        self.create_resized_image(File.join(output_dir,name),geometry_string)
    end

    def get_resized_name(path, type)
        name = File.basename(path,'.*')
        case type
            when :jpeg then name += '.jpg'
            when :jpg then name += '.jpg'
            when :png then name += '.png'
            else name = File.basename(path)
        end
        return name
    end
end
