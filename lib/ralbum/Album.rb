require 'rubygems'
require 'bundler/setup'

require 'json'
require 'ralbum/Image'
require 'ralbum/module_observable'

module Ralbum
    class Album
        include Observable

        attr :path
        attr_reader :title, :subtitle, :description, :destination, :images, :template, :album_info
        attr_writer :title, :subtitle, :description, :destination, :template

        def initialize(path)
            raise IOError, "directory does not exist: #{path}" if not Dir.exists?(path)
            @path = File.expand_path(path)
            @album_info = self.get_album_info
            @images = self.collect_images(@album_info['images'])
        end

        def title
            return @album_info['title']
        end

        def title=(value)
            @album_info['title'] = value
            self
        end

        def subtitle
            return @album_info['subtitle']
        end
        def subtitle=(value)
            @album_info['subtitle'] = value
            self
        end

        def destination
            return @album_info['destination']
        end
        def destination=(value)
            @album_info['destination'] = value
            self
        end

        def description
            return @album_info['description']
        end
        def description=(value)
            @album_info['description'] = value
            self
        end

        def template
            return @album_info['template']
        end
        def template=(value)
            @album_info['template'] = value
            self
        end

        def author
            return @album_info['author']
        end

        def author=(value)
            @album_info['author'] = value
            self
        end

        def copyright
            return @album_info['copyright']
        end

        def copyright=(value)
            @album_info['copyright'] = value
            self
        end


        ##
        # creates an album.json file, and invokes the json creation for each
        # image found in the album
        def create(options = {})
            @images = []
            info = self.get_new_info
            Dir.entries(@path).find_all { |f| File.file?(File.join(@path,f)) }.map{|f| File.join(@path,f)}.each do |f|
                begin
                    img = Image.new(f)
                    img.create
                    @images << img
                    yield img if block_given?
                    info['images'] << File.basename(f)
                rescue
                end
            end

            @album_info = info
            (@album_info['title'] = options['title']) if options.key?('title')
            (@album_info['subtitle'] = options['subtitle']) if options.key?('subtitle')
            (@album_info['description'] = options['description']) if options.key?('description')
            (@album_info['author'] = options['author']) if options.key?('author')
            (@album_info['copyright'] = options['copyright']) if options.key?('copyright')
            self.write_albuminfo
        end

        def write_albuminfo
            FileUtils.mkdir_p(File.dirname self.json_path)
            images = @images.map {|img| File.basename(img.path)}
            @album_info['images'] = images
            open(self.json_path,'w') do |f|
               f.write(JSON.pretty_generate(@album_info))
            end
        end

        def json_path
            File.expand_path(File.join(@path,'.ralbum','album.json'))
        end

        def get_new_info
            {
                "title" => File.basename(@path),
                "subtitle" => '',
                "description" => '',
                "author" => '',
                "copyright" => '',
                "images" => [],
                "template" => nil,
                "destination" => nil
            }
        end

        ##
        # Reads the album metainfo from the album.json file, if present,
        # or sets apropriate defaults.
        def get_album_info
            info = self.get_new_info
            if File.exists?(json_path)
                begin
                    data = JSON.parse(File.read(json_path))
                    if data.respond_to?(:key?)
                        (info['title'] = data['title']) if data.key?('title')
                        (info['subtitle'] = data['subtitle']) if data.key?('subtitle')
                        (info['description'] = data['description']) if data.key?('description')
                        (info['author'] = data['author']) if data.key?('author')
                        (info['copyright'] = data['copyright']) if data.key?('copyright')
                        (info['images'] = data['images']) if data.key?('images')
                        (info['template'] = data['template']) if data.key?('template')
                        (info['index'] = data['index']) if data.key?('index')
                        (info['detail'] = data['detail']) if data.key?('detail')
                        (info['destination'] = data['destination']) if data.key?('destination')
                    end
                rescue
                end
            end
            return info
        end

        ##
        # fetches all the imags in the album dir, creating Image instances from them
        # and return an array of Image objects.
        def collect_images(image_names, folder = nil)
            folder = @path if not folder
            images = []
            image_names.each do | imgname |
                imgpath = File.join(folder,imgname)
                begin
                    img = Image.new(imgpath)
                    if img.type
                        images << img
                        yield img if block_given?
                    end
                rescue
                end
            end
            return images
        end

        def image_index(image) 
            return @images.index(image)
        end

        def update
            img_files = Dir.entries(@path).find_all { |f| File.file?(File.join(@path,f)) }.map{|f| File.join(@path,f)}

            # The following situation could happen:
            # 1. when the Image object is present, the image config and the file is OK, no action needed.
            # 2. remaining image files need to be added
            # 3. orphaned config files need to be removed
            new_images = []
            @images.each_with_index do | img, index |
                # all images in the @images array are still OK and present, we just re-append them:
                new_images << img

                # remove entry from the found image files, as those are OK:
                img_files.delete_if {|img_file| File.basename(img_file) == File.basename(img.path)}
            end
            @images = new_images

            # remaining image files without album entry: we need to process them as new images:
            img_files.each do | new_file |
                begin
                    img = Image.new(new_file)
                    self.inform_listeners(:update, "new image found: #{new_file}")
                    img.create
                    @images << img
                rescue
                end
            end
            self.write_albuminfo
        end
    end
end
