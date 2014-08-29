require 'rubygems'
require 'bundler/setup'

require 'json'
require 'lib/Image'

class Album
    attr :path
    attr_reader :title, :subtitle, :description, :images

    def initialize(path)
        raise IOError, "directory does not exist: #{path}" if not Dir.exists?(path)
        @path = File.expand_path(path)
        @album_info = self.get_album_info
        @images = self.collect_images(@album_info['images'])
    end

    def title
        return @album_info['title']
    end

    def subtitle
        return @album_info['subtitle']
    end

    def description
        return @album_info['description']
    end

    ##
    # creates an album.json file, and invokes the json creation for each
    # image found in the album
    def create
        @images = []
        info = self.get_new_info
        Dir.entries(@path).find_all { |f| File.file?(File.join(@path,f)) }.map{|f| File.join(@path,f)}.each do |f|
            begin
                img = Image.new(f)
                img.create
                @images << img
                info['images'] << File.basename(f)
            rescue
            end
        end

        @album_info = info

        open(self.json_path,'w') do |f|
           f.write(JSON.generate(@album_info))
        end
    end

    def json_path
        File.expand_path(File.join(@path,'album.json'))
    end

    def get_new_info
        {
            "title" => File.basename(@path),
            "subtitle" => '',
            "description" => '',
            "images" => []
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
                    (info['images'] = data['images']) if data.key?('images')
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
                (images << img) if img.type
            rescue
            end
        end
        return images
    end
end
