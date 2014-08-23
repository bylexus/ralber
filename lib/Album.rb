require 'json'

class Album
    attr :path
    attr_reader :album_info
    attr_reader :images

    def initialize(path = nil)
        @path = File.expand_path(path) if path
        @title = File.basename(path) if path
        @images = []
    end

    def create
        raise StandardError, 'directory does not exists' if not Dir.exists?(@path)
        open(self.album_json_path,'w') do |f|
           f.write(JSON.generate(self.album_info))
        end
    end

    def album_json_path
        File.expand_path(File.join(@path,'album.json'))
    end

    def album_info
        info = {
            "path" => @path,
            "title" => @title
        }
    end
end
