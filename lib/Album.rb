require 'rubygems'
require 'bundler/setup'

require 'json'

class Album
    attr :path
    attr_reader :title, :subtitle, :description
    attr_reader :images

    def initialize(path)
        raise IOError, "directory does not exist: #{path}" if not Dir.exists?(path)
        @path = File.expand_path(path)
        @album_info = self.get_album_info
        @images = self.collect_images
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
        open(self.json_path,'w') do |f|
           f.write(JSON.generate(@album_info))
        end
        @images.each do |img|
            img.create
        end
    end

    def json_path
        File.expand_path(File.join(@path,'album.json'))
    end

    ##
    # Reads the album metainfo from the album.json file, if present,
    # or sets apropriate defaults.
    def get_album_info
        info = {
            "title" => File.basename(@path),
            "subtitle" => '',
            "description" => ''
        }
        if File.exists?(json_path)
            begin
                data = JSON.parse(File.read(json_path))
                if data.respond_to?(:key?)
                    (info['title'] = data['title']) if data.key?('title')
                    (info['subtitle'] = data['subtitle']) if data.key?('subtitle')
                    (info['description'] = data['description']) if data.key?('description')
                end
            rescue
            end
        end
        return info
    end

    ##
    # fetches all the imags in the album dir, creating Image instances from them
    # and return an array of Image objects.
    def collect_images
        images = []
        Dir.entries(@path).find_all { |f| File.file?(File.join(@path,f)) }.map{|f| File.join(@path,f)}.each do |f|
            begin
                img = Image.new(f)
                (images << img) if img.type
            rescue
            end
        end
        return images
    end
end
