require 'rubygems'
require 'bundler/setup'
require 'digest'
require 'json'
require 'rmagick'
require 'exifr'

module Ralber

    ##
    # Represents an image with its metadata. Performs also converting
    # functions like thumbs etc.
    class Image
        attr :path
        attr_reader :exif

        def initialize(path)
            raise StandardError, "File does not exits" if not File.exists?(path)
            @path = File.expand_path(path)
            @image_info = self.get_image_info
            @exif = self.exif_data
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
        def published_md5
            @image_info['published_md5']
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
            @image_info['published_md5'] = meta[:published_md5]

            self.write_imageinfo
        end

        def write_imageinfo
            FileUtils.mkdir_p(File.dirname json_path)
            data = @image_info.clone
            data[:exif] = @exif
            open(self.json_path,'w') do |f|
                f.write(JSON.pretty_generate(data))
            end
        end

        def json_path
            dir = File.join(File.dirname(@path),'.ralber')
            base = File.basename(@path)
            File.expand_path(File.join(dir,base+'.json'))
        end

        def get_new_info
            {
                "title" => File.basename(@path),
                "type" => nil,
                "description" => '',
                "width" => 0,
                "height" => 0,
                "published_md5" => ''
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
                        (info['published_md5'] = data['published_md5']) if data.key?('published_md5')
                    end
                rescue
                end
            else
                self.create
                info = @image_info
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
                :type => self.map_type(img.format),
                :published_md5 => ''
            }
        end

        def exif_data
            data = {
                :exif => false,
                :width => nil,
                :height => nil,
                :date_time => nil,
                :date_time_original => nil,
                :gps_longitude => 0.0,
                :gps_latitude => 0.0,
                :gps_altitude => 0.0,
                :exposure_time => nil,
                :focal_length => nil,
                :f_number => nil
            }
            if self.type == :jpeg
                begin
                    exifr = EXIFR::JPEG.new(@path)
                    data[:exif] = exifr.exif?
                    data[:width] = exifr.width
                    data[:height] = exifr.height
                    data[:date_time] = exifr.date_time
                    data[:date_time_original] = exifr.date_time_original
                    data[:gps_longitude] = exifr.gps.longitude || 0.0
                    data[:gps_latitude] = exifr.gps.latitude || 0.0
                    data[:gps_altitude] = exifr.gps.altitude || 0.0
                    data[:exposure_time] = exifr.exposure_time
                    data[:focal_length] = exifr.focal_length
                    data[:f_number] = exifr.f_number
                rescue
                end
            end
            return data
        end

        def map_type(imagickType)
            case imagickType
                when 'JPEG' then :jpeg
                when 'PNG' then :png
                when 'GIF' then :gif
                else nil
            end
        end

        def create_resized_image(output_filename, geometry_string = nil)
            img = Magick::Image::read(@path).first
            if geometry_string
                img.change_geometry!(geometry_string) { |cols, rows, manipImg|
                    img.resize!(cols, rows)
                }
            end
            img.write(output_filename)
        end

        def create_resized_version(type, geometry_string, output_dir)
            name = self.get_resized_name(@path, type)
            outfile = File.join(output_dir,name)
            self.create_resized_image(outfile,geometry_string)
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

        def calc_md5
            if not @md5_calculated
                @md5_calculated = Digest::MD5.file(@path).hexdigest
            end
            return @md5_calculated
        end

        def has_changed
            self.calc_md5() != self.published_md5
        end

        def update_md5
            @image_info['published_md5'] = self.calc_md5
            self.write_imageinfo
        end

        def update
            self.update_md5
        end
    end
end
